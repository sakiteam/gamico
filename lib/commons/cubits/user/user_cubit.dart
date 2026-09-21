import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/database_shutdown.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/services/gratification.dart';
import 'package:gamico/commons/services/player_name_service.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';

part 'user_state.dart';

class GamicoUserCubit extends Cubit<GamicoUserState> {
  GamicoUserCubit({required this.usersRepository})
    : super(const GamicoUserState()) {
    GamicoDatabaseShutdown.register(this, cancelDatabaseListeners);
  }

  bool _managed = false;
  GamicoUsersRepository usersRepository;
  StreamSubscription? _streamSubscription;
  OnDisconnect? _disconnectionReference;
  final Map<String, StreamSubscription<DatabaseEvent>> _fieldSubscriptions = {};

  static const _watchedFields = <String>{
    "created_at",
    "name",
    "formatted_name",
    "social_name",
    "photo",
    "type",
    "blocked",
    "coins",
    "level",
    "stars",
    "trophies",
    "victories",
    "defeats",
    "achievements",
    "progression",
    "streak",
    "skins",
    "active_skin",
    "premium",
    "last_gratification",
    "next_gratification",
    "gratified_at",
  };

  /// The uid [_fieldSubscriptions] belong to, so a re-entrant
  /// [listenToUserChanges] can tell "already watching this user" from a real
  /// account switch.
  String? _watchedUid;

  /// `users/$_watchedUid`, kept as a field so the presence write can reach it
  /// from outside [listenToUserChanges].
  DatabaseReference? _userReference;

  /// Set when `created_at` reports null: the node itself is gone (account
  /// deleted). See [_applyUserField].
  bool _nodeGone = false;

  /// The one and only `.info/connected` subscription. Both things that react
  /// to connectivity — the server-sync probe and the presence write — hang off
  /// it rather than each opening its own listener on the same path.
  StreamSubscription<DatabaseEvent>? _connectionSubscription;
  bool _connected = false;

  /// Backs [GamicoUserState.serverSynced]. Reset on an account switch.
  bool _serverSynced = false;

  /// Whether presence is this cubit's to write — the host app can keep it,
  /// see [UserSettings.managePresence].
  bool _presenceManaged = false;

  /// Watches connectivity for the account [listenToUserChanges] just attached
  /// to, and drives everything that depends on it.
  void _watchConnection() {
    _connectionSubscription?.cancel();
    _connectionSubscription = FirebaseDatabase.instance
        .ref(".info/connected")
        .onValue
        .listen((event) {
          _connected = event.snapshot.value as bool? ?? false;
          if (!_connected) return;

          _probeServerSync();
          _publishPresence();
        }, onError: (e) => debugPrint("⚠️ .info/connected ERROR => $e"));
  }

  /// Flips [GamicoUserState.serverSynced] once the account has actually been
  /// round-tripped with the backend.
  ///
  /// Disk persistence is on, so the listener's first payload can come straight
  /// off the disk cache — a snapshot of this device's last session, possibly
  /// behind the account. RTDB exposes no "this came from cache" marker, so the
  /// round trip has to be observed from the outside.
  ///
  /// The marker is a one-shot read of a single leaf. Waiting for a second
  /// `onValue` would not work: when the cache already matches the server, the
  /// value never changes and no further event is ever delivered. Issuing a read
  /// over a live socket does reach the backend, and by the time it answers the
  /// listener has been handed the authoritative node.
  Future<void> _probeServerSync() async {
    final ref = _userReference;
    if (ref == null || _serverSynced) return;

    try {
      await ref.child("created_at").get();
    } catch (e) {
      debugPrint("⚠️ server-sync probe failed => $e");
      return;
    }

    if (isClosed || _serverSynced) return;

    _serverSynced = true;
    emit(state.copyWith(serverSynced: true));
  }

  /// Publishes `online: true` and arms the `onDisconnect` that clears it.
  ///
  /// Re-run on every reconnection: an `onDisconnect` is consumed when it
  /// fires, so it has to be registered again each time the socket comes back.
  void _publishPresence() {
    final ref = _userReference;
    if (ref == null || !_presenceManaged || !_connected) return;

    final user = state.user;
    final isUserComplete =
        user != null &&
        (user.socialId != null || user.firebaseId != null || user.name != null);

    if (!state.loaded || !isUserComplete) {
      debugPrint(
        "⚠️ [UserCubit] Connexion détectée mais l'utilisateur n'est pas "
        "complètement chargé. Mise à jour de présence ignorée.",
      );
      return;
    }

    final now = DateTime.now();

    _disconnectionReference = ref.onDisconnect();
    _disconnectionReference?.update({"online": false, "updated_at": "$now"});

    ref.update({"online": true, "updated_at": "$now"});
  }

  /// Decides, once a complete user payload has arrived, whether presence is
  /// ours to write — and publishes it right away if the socket is already up.
  void _manageDisconnection() {
    // Never operate on an empty uid: `ref("users/")` resolves to the `users`
    // collection ROOT, and writing online/updated_at there corrupts the shared
    // user store. (Mirrors the guard already in Ludiko's connecto UserCubit.)
    if (LocalStorageService.uid.isEmpty) return;

    // Marking it managed keeps [manageUserChanges] from retrying on every
    // payload, whether or not presence turns out to be ours.
    _managed = true;

    // The host app may own presence itself — see [UserSettings.managePresence].
    if (!Gamico.instance.userSettings.managePresence) return;

    _presenceManaged = true;
    _publishPresence();
  }

  void unlockAchievement(String id, [double percentage = 100, int steps = 0]) {
    if (!LocalStorageService.authenticated) return;

    if (state.isAchivementUnlocked(id)) return;

    unawaited(_submitAchievement(id, percentage, steps));

    // Fire-and-forget: an achievement mirror that fails (offline, rules,
    // a sign-out mid-flight) must not surface as an unhandled async error.
    FirebaseDatabase.instance
        .ref("users/${LocalStorageService.uid}/achievements/$id")
        .set(percentage)
        .catchError((e) => debugPrint("⚠️ achievement set error => $e"));

    if (percentage == 100) {
      incrementCoins(3);
    }
  }

  /// Waits for the platform game services to come up, then pushes the
  /// achievement to Game Center / Play Games.
  Future<void> _submitAchievement(
    String id,
    double percentage,
    int steps,
  ) async {
    await GamicoGlobalService.waitWhile(() => !PlayService.gameServicesEnabled);

    Achievements.unlock(
      achievement: Achievement(
        androidID: id,
        iOSID: id,
        percentComplete: percentage,
        steps: steps,
      ),
    );
  }

  /// Whether a write may be issued for this account at all.
  ///
  /// `state.user != null` is NOT that test. The cubit is seeded from the
  /// LocalStorage copy in its constructor, so a user is present from the very
  /// first frame — the one from this device's LAST session, which can be behind
  /// the account (session killed before a write landed, a game played on
  /// another device, a reinstall). Publishing anything derived from it before
  /// the listener has spoken republishes that stale snapshot over the real
  /// account, and the listener then syncs the local copy onto the value it just
  /// clobbered: a level that "goes back" a little more on every app open.
  ///
  /// This is the FLOOR, not the ceiling. It clears relative writes (increments)
  /// and monotonic ones (max-transactions), which are correct whatever the
  /// local copy holds — that is the whole point of having converted the
  /// counters and the levels to them. An absolute read-modify-write needs the
  /// stricter [canPublishAbsoluteUser].
  bool get canPersistUser =>
      LocalStorageService.uid.isNotEmpty && state.loaded && state.user != null;

  /// Whether [state.user] may be used as the BASE of an absolute write — one
  /// that replaces a value rather than nudging it.
  ///
  /// Stricter than [canPersistUser] because `loaded` does not mean "came from
  /// the server": disk persistence is enabled, so the listener's first payload
  /// on a cold start is served from disk. Only [GamicoUserState.serverSynced]
  /// says the account has been round-tripped with the backend this session.
  bool get canPublishAbsoluteUser => canPersistUser && state.serverSynced;

  void updateUserLevel(int level) {
    if (!canPersistUser) {
      debugPrint(
        "⚠️ updateUserLevel($level) BLOCKED (account not loaded from server) "
        "userNull=${state.user == null} loaded=${state.loaded}",
      );
      return;
    }

    // Raised, never set: the comparison happens against the value on the
    // server, so no stale device can walk the level backwards even if it gets
    // past the guard above.
    usersRepository.raiseUserLevel(LocalStorageService.uid, level);
  }

  /// Writes one field of one progression namespace. Narrower than
  /// [updateUserProgression]: it cannot touch another game, and it does not
  /// need the whole `progression` map to be rebuilt locally first.
  void updateUserProgressionEntry(String gameKey, String field, Object? value) {
    if (!canPersistUser) return;
    usersRepository.updateUserProgressionField(
      LocalStorageService.uid,
      gameKey,
      field,
      value,
    );
  }

  /// Applies relative deltas to the counters of one progression namespace
  /// (paths relative to `progression/{gameKey}`, e.g. `"online/victories"`).
  ///
  /// Prefer this to [updateUserProgression] for anything that counts: the
  /// server increments its own value, so a concurrent device — or a stale local
  /// copy — cannot overwrite a count with a lower one.
  void incrementProgression(String gameKey, Map<String, num> deltas) {
    if (!canPersistUser) return;
    usersRepository.incrementUserProgressionFields(
      LocalStorageService.uid,
      gameKey,
      deltas,
    );
  }

  /// Raises one progression field, never lowers it. Used for per-game levels.
  ///
  /// Resolves to true once the server has settled the write; it never resolves
  /// while offline, which is how [GamicoProgressionService] knows to keep the
  /// gain queued.
  Future<bool> raiseProgressionField(
    String gameKey,
    String field,
    int value,
  ) async {
    if (!canPersistUser) return false;
    return usersRepository.raiseUserProgressionField(
      LocalStorageService.uid,
      gameKey,
      field,
      value,
    );
  }

  /// Merges an adventure star list element-wise, keeping the better score of
  /// each chapter.
  Future<bool> mergeProgressionStars(String gameKey, List<int> stars) async {
    if (!canPersistUser) return false;
    return usersRepository.mergeUserProgressionStars(
      LocalStorageService.uid,
      gameKey,
      stars,
    );
  }

  /// Mirrors a namespace locally without writing anything, so the UI reflects
  /// a result immediately while the atomic writes above travel to the server
  /// and echo back through the `progression` listener.
  void mirrorProgression(String gameKey, Map<String, dynamic> namespace) {
    final current = state.user;
    if (current == null) return;

    final json = Map<String, dynamic>.from(Gamico.instance.userToJson(current));
    final progression = Map<String, dynamic>.from(
      (json["progression"] as Map?) ?? const <String, dynamic>{},
    );
    progression[gameKey] = namespace;
    json["progression"] = progression;

    emit(state.copyWith(user: () => Gamico.instance.userFromJson(json)));
  }

  /// Emits a signal distinct from [incrementCoins]'s `cowriesUpdate` so a
  /// "challenge completed" banner can react specifically to this event rather
  /// than any coin gain (an ad reward or a match-win payout must not trigger
  /// it). [gameKey] lets multiple games share this cubit without cross-firing
  /// each other's banners.
  void notifyChallengeCompleted(String gameKey) {
    emit(
      state.copyWith(
        challengeCompletedSignal: state.challengeCompletedSignal + 1,
        challengeCompletedGameKey: gameKey,
      ),
    );
  }

  void updateUserProgression(Map<String, dynamic> progression) {
    if (LocalStorageService.uid.isEmpty) return;

    // [GAMICO-FIX] name/level-loss investigation.
    // Guard: callers build `progression` by merging onto the current
    // `state.user.progression`, so this write is only as correct as the user it
    // merged onto. Until the server node has arrived that user is the
    // LocalStorage copy from the last session — see [canPersistUser] for why
    // publishing it is what makes a progression go backwards.
    if (!canPublishAbsoluteUser) {
      debugPrint(
        "⚠️ updateUserProgression BLOCKED (account not synced with the server) "
        "loaded=${state.loaded} synced=${state.serverSynced} "
        "userNull=${state.user == null} progression=$progression",
      );
      return;
    }

    // Optimistically update the local state to prevent read-modify-write
    // race conditions when multiple updates are fired synchronously
    // (e.g. setUserStars followed immediately by setUserLevel).
    final previous = Map<String, dynamic>.from(
      state.user!.progression ?? const <String, dynamic>{},
    );

    final updatedUser = Gamico.instance.userFromJson(
      Map<String, dynamic>.from(Gamico.instance.userToJson(state.user!))
        ..["progression"] = progression,
    );

    emit(state.copyWith(user: () => updatedUser));

    // Only the namespaces that actually changed, each at its own path.
    //
    // Callers all follow the same shape: take `state.user.progression`, edit
    // the one namespace their game owns, hand the whole map back. Persisting
    // that map wholesale meant a single Crazy Eights win re-uploaded — and had
    // echoed back to it — Ludo's, Hex's, Awalo's and every other game's stats
    // as well. The diff below is against the map those callers merged onto, so
    // it isolates exactly the namespace they touched.
    //
    // Comparison is by encoded form: it can call an unchanged namespace changed
    // (harmless, that is just today's behaviour for that one key) but never the
    // reverse, so no edit can be silently dropped.
    final changed = <String, dynamic>{};
    for (final entry in progression.entries) {
      if (jsonEncode(previous[entry.key]) != jsonEncode(entry.value)) {
        changed[entry.key] = entry.value;
      }
    }
    // A namespace the caller dropped must still be deleted: setting the whole
    // node used to remove it implicitly.
    for (final key in previous.keys) {
      if (!progression.containsKey(key)) changed[key] = null;
    }

    usersRepository.updateUserProgressionEntries(
      LocalStorageService.uid,
      changed,
    );
  }

  /// Persists the daily-open streak. Refuses until the account is synced, for
  /// the same reason [updateUserProgression] does: the caller reconciles
  /// against `user.streak`, so reconciling against a stale copy would publish a
  /// count lower than the one the account holds.
  void updateUserStreak(Map<String, dynamic> streak) {
    if (!canPublishAbsoluteUser) return;

    // Mirror it locally first so a read straight after the call already sees
    // the new value, as the progression writer does.
    final updatedUser = Gamico.instance.userFromJson(
      Map<String, dynamic>.from(Gamico.instance.userToJson(state.user!))
        ..["streak"] = streak,
    );
    emit(state.copyWith(user: () => updatedUser));

    usersRepository.updateUserStreak(LocalStorageService.uid, streak);
  }

  void setUser(GamicoUserModel? user, {bool loaded = false}) {
    emit(state.copyWith(user: () => user, loaded: loaded));
  }

  /// Player-initiated rename. Only touches `name`/`formatted_name`.
  Future<GamicoNameUpdateResult> updateUserName(String name) async {
    if (!LocalStorageService.authenticated || LocalStorageService.uid.isEmpty) {
      return GamicoNameUpdateResult.unauthenticated;
    }

    final sanitized = GamicoPlayerNameService.sanitizeName(name);

    if (!GamicoPlayerNameService.isNameValid(sanitized)) {
      return GamicoNameUpdateResult.invalid;
    }

    // Same name (possibly re-cased): nothing to check, nothing to conflict on.
    if (sanitized ==
        GamicoPlayerNameService.sanitizeName(state.user?.name ?? "")) {
      return GamicoNameUpdateResult.success;
    }

    final formatted = GamicoPlayerNameService.formatName(sanitized);
    final taken = await GamicoPlayerNameService.isNameTaken(formatted);

    if (taken == null) return GamicoNameUpdateResult.failure;
    if (taken) return GamicoNameUpdateResult.taken;

    return await _writeName(sanitized)
        ? GamicoNameUpdateResult.success
        : GamicoNameUpdateResult.failure;
  }

  /// Writes the name to the SERVER and reports whether it actually landed.
  ///
  /// A name that only changed locally would break every player looking this
  /// one up, so the caller must be able to tell the player it failed. Note
  /// that RTDB keeps a write pending forever while offline instead of failing,
  /// so this reports failure only on a real error, never on "no network".
  Future<bool> _writeName(String name) async {
    try {
      await usersRepository.updateUserName(LocalStorageService.uid, name);
    } catch (e) {
      debugPrint("⚠️ updateUserName failed: $e");
      return false;
    }

    // Best-effort mirror: the game reads the name from RTDB, an Auth sync
    // failure is not critical.
    FirebaseAuth.instance.currentUser?.updateDisplayName(name).catchError((e) {
      debugPrint("⚠️ updateDisplayName failed (ignored): $e");
    });

    return true;
  }

  void listenToUserChanges() {
    if (GamicoDatabaseShutdown.shuttingDown) return;

    final uid = LocalStorageService.uid;
    if (uid.isEmpty) return;

    // [onChange] re-enters here on every null -> non-null user transition,
    // which includes the one this method's own first payload causes. Without
    // this guard that re-entry tore the listener down and re-attached it —
    // and an RTDB attach always re-sends the node in full, so the very first
    // load used to be paid for twice.
    if (_watchedUid == uid &&
        (_fieldSubscriptions.isNotEmpty || _streamSubscription != null)) {
      return;
    }

    _streamSubscription?.cancel();
    _cancelFieldSubscriptions();
    _watchedUid = uid;
    _nodeGone = false;
    _serverSynced = false;

    // The flag is mirrored in the state, and the previous account's `true`
    // must not carry over: [canPublishAbsoluteUser] reads the state one, so
    // leaving it set would clear absolute writes against a disk-cache user.
    if (state.serverSynced) emit(state.copyWith(serverSynced: false));

    final ref = FirebaseDatabase.instance.ref("users/$uid");
    _userReference = ref;

    _watchConnection();

    // The full node, but only until it has loaded once.
    //
    // It stays a listener rather than a one-shot `get()` on purpose: the first
    // payload can legitimately be refused (see the `partial` guard in
    // [manageUserChanges] — a cold cache echoing one of our own writes back at
    // us looks exactly like a corrupted node), and a listener keeps waiting
    // for a good one where a `get()` would leave `loaded` false for good and
    // strand the sign-in that waits on it.
    _streamSubscription = ref.onValue.listen((event) {
      manageUserChanges(event);
      // A user is loaded: the whole node has now been downloaded once, which
      // is all it was ever needed for. Everything after this arrives leaf by
      // leaf instead.
      if (state.user != null) _swapToFieldListeners(ref);
    }, onError: (e) => debugPrint("⚠️ users/$uid onValue ERROR => $e"));
  }

  /// Drops the full-node listener and replaces it with one listener per
  /// [_watchedFields] entry, so a write to any single field costs that field
  /// and not the whole profile.
  void _swapToFieldListeners(DatabaseReference ref) {
    if (_fieldSubscriptions.isNotEmpty) return;

    // Safe from inside the full-node listener's own callback: cancelling a
    // subscription from its handler is allowed, and the handler cannot run
    // before `listen()` returned (RTDB events cross a platform channel, so
    // they are always delivered asynchronously).
    _streamSubscription?.cancel();
    _streamSubscription = null;

    for (final field in _watchedFields) {
      _fieldSubscriptions[field] = ref
          .child(field)
          .onValue
          .listen(
            (event) => _applyUserField(field, event.snapshot.value),
            onError: (_) {},
          );
    }
  }

  /// Merges one changed field into the loaded user.
  ///
  /// Same merge the `partial` branch of [manageUserChanges] performs, and for
  /// the same reason: identity (`social_id`, `firebase_id`, `created_at`) and
  /// every unwatched field come from the user already in state, so a single
  /// leaf can never blank the rest of the profile.
  void _applyUserField(String field, Object? value) {
    if (_nodeGone) return;

    // `created_at` is immutable once written, so the only way it can report
    // null is the node no longer existing at all. A deleted node is
    // deliberately ignored rather than acted on — [manageUserChanges] only
    // ever applies non-null payloads — and swallowing the leaf storm a
    // deletion sends keeps that behaviour here too, instead of blanking the
    // user field by field.
    if (field == "created_at" && value == null) {
      _nodeGone = true;
      return;
    }

    final current = state.user;
    if (current == null) return;

    final json = Map<String, dynamic>.from(Gamico.instance.userToJson(current));
    final next = value == null ? null : jsonDecode(jsonEncode(value));

    // Every listener fires once on attach, so without this the swap would emit
    // one identical state per watched field.
    if (jsonEncode(json[field]) == jsonEncode(next)) return;

    json[field] = next;

    final merged = Gamico.instance.userFromJson(json);
    setUser(merged, loaded: true);
  }

  /// Applies a full-node payload. A null one (a deleted or unreadable node) is
  /// ignored on purpose: signing the player out on it cost accounts to
  /// transient RTDB nulls, so the last known user is kept instead.
  void manageUserChanges(DatabaseEvent event) {
    if (event.snapshot.value == null) return;

    final json = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(event.snapshot.value)),
    );

    // [GAMICO-FIX] name/level-loss investigation.
    // A genuine user node always carries an identity — social_id /
    // firebase_id — or at least the created_at stamped at creation. A
    // payload with NONE of them is not a full user: it is either a
    // corrupted/ghost node (reduced to {updated_at}), or RTDB's latency
    // compensation echoing back one of the app's OWN partial writes on a
    // cold cache (renaming writes {name, formatted_name, updated_at}).
    //
    // Applying such a payload as-is would wipe the loaded user — coins,
    // level, everything — and persist the stub locally, so it resurfaces
    // all-null on the next restart.
    final partial =
        json["social_id"] == null &&
        json["firebase_id"] == null &&
        json["created_at"] == null;

    if (partial) {
      final current = state.user;

      if (current == null) {
        debugPrint(
          "⚠️ manageUserChanges: ignoring partial/corrupted user payload for "
          "users/${LocalStorageService.uid}: ${event.snapshot.value}",
        );
        return;
      }

      // Keep the loaded user and apply only the fields that changed: the
      // rename must still show up immediately.
      final merged = Map<String, dynamic>.from(
        Gamico.instance.userToJson(current),
      )..addAll(json);

      setUser(Gamico.instance.userFromJson(merged), loaded: true);

      // Deliberately no _manageDisconnection() here: that write would keep
      // a ghost node alive if this payload really is a corrupted one.
      return;
    }

    final value = Gamico.instance.userFromJson(json);
    setUser(value, loaded: true);

    if (!_managed) {
      _manageDisconnection();
    }
  }

  /// Drops every database listener without touching the state: called while the
  /// app is being torn down, so no RTDB event can reach a dead engine.
  Future<void> cancelDatabaseListeners() => _teardown(resetState: false);

  /// Same, plus the state reset: called on sign-out, where the UI must stop
  /// treating the (no longer watched) user as live.
  void cancelUserChangesListener() => unawaited(_teardown(resetState: true));

  /* UPDATE */

  void incrementLevel() {
    usersRepository.incrementUserLevel(LocalStorageService.uid);
  }

  void updateStars(List<int> stars) {
    usersRepository.updateUserStars(LocalStorageService.uid, stars);
  }

  void setSocialName(String socialName) {
    usersRepository.updateUserSocialName(LocalStorageService.uid, socialName);
  }

  void setPhoto(String? photo) {
    if (photo == null) return;
    if (photo == state.user?.photo) return;

    usersRepository.updateUserPhoto(LocalStorageService.uid, photo);
  }

  Future<void> setToken() async {
    void updateToken(String? token) {
      usersRepository.updateUserToken(LocalStorageService.uid, token);
    }

    try {
      if (Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        if (apnsToken == null) {
          await Future.delayed(const Duration(minutes: 1));
          return unawaited(setToken());
        }
      }

      updateToken(await FirebaseMessaging.instance.getToken());

      FirebaseMessaging.instance.onTokenRefresh.listen(updateToken);
    } catch (e) {
      debugPrint("$e");
    }
  }

  void setGratification(int last, int next) {
    incrementCoins(last);

    usersRepository.updateUserGratification(
      LocalStorageService.uid,
      last,
      next,
    );

    GratificationService.gratifiedAt = DateTime.now();
  }

  void setSkins(Map<String, dynamic> skins) {
    usersRepository.updateUserSkins(LocalStorageService.uid, skins);
  }

  void setPremium() {
    usersRepository.updateUserPremium(LocalStorageService.uid, true);
  }

  /* LEADERBOARDS */

  void incrementVictories() {
    final finalCrowns = (state.user?.trophies ?? 0) + 1;

    usersRepository.incrementTrophies(LocalStorageService.uid);

    _submitTacticiansScore(finalCrowns);
  }

  void incrementDefeats() {
    final trophies = (state.user?.trophies ?? 0) - 1;

    usersRepository.decrementTrophies(
      LocalStorageService.uid,
      trophies >= 0 ? 1 : 0,
    );

    if (trophies >= 0) {
      _submitTacticiansScore(trophies);
    }
  }

  void incrementCoins([int coins = 1]) {
    emit(
      state.copyWith(
        cowriesUpdate: state.cowriesUpdate + 1,
        cowriesUpdateDifference: coins,
      ),
    );

    final nextCoins = (state.user?.coins ?? 0) + coins;

    usersRepository.incrementUserCoins(LocalStorageService.uid, coins);

    _submitCollectorsScore(nextCoins);
  }

  void decrementCoins([int coins = 1]) {
    final userDiamonds = (state.user?.coins ?? 0);
    final cowriesToDecrement = min(coins, userDiamonds);

    if (cowriesToDecrement == 0) return;

    emit(
      state.copyWith(
        cowriesUpdate: state.cowriesUpdate + 1,
        cowriesUpdateDifference: -cowriesToDecrement,
      ),
    );

    usersRepository.decrementUserCoins(
      LocalStorageService.uid,
      cowriesToDecrement,
    );

    _submitCollectorsScore(max(userDiamonds - coins, 0));
  }

  void _submitCollectorsScore(int score) {
    if (!PlayService.gameServicesEnabled) return;

    if ((Gamico.instance.playSettings?.inactivePlayersLeaderboardId ?? "")
        .isEmpty) {
      return;
    }

    Leaderboards.submitScore(
      score: Score(
        androidLeaderboardID:
            Gamico.instance.playSettings?.inactivePlayersLeaderboardId,
        iOSLeaderboardID:
            Gamico.instance.playSettings?.inactivePlayersLeaderboardId,
        value: score,
      ),
    );
  }

  void _submitTacticiansScore(int score) {
    if (!PlayService.gameServicesEnabled) return;

    if ((Gamico.instance.playSettings?.activePlayersLeaderboardId ?? "")
        .isEmpty) {
      return;
    }

    Leaderboards.submitScore(
      score: Score(
        androidLeaderboardID:
            Gamico.instance.playSettings?.activePlayersLeaderboardId,
        iOSLeaderboardID:
            Gamico.instance.playSettings?.activePlayersLeaderboardId,
        value: score,
      ),
    );
  }

  /* CLEAN */

  void _cancelFieldSubscriptions() {
    for (final subscription in _fieldSubscriptions.values) {
      subscription.cancel();
    }

    _fieldSubscriptions.clear();
  }

  /// The single teardown path, so the shutdown hook, the sign-out and [close]
  /// can no longer drift apart and leave one subscription behind each.
  ///
  /// [resetState] also clears `loaded`/`serverSynced` — the sign-out case. The
  /// shutdown and close cases leave the state alone: nothing will read it
  /// again anyway, and emitting on a closing cubit throws.
  Future<void> _teardown({required bool resetState}) async {
    _managed = false;
    _presenceManaged = false;
    _connected = false;
    _serverSynced = false;
    _nodeGone = false;
    _watchedUid = null;
    _userReference = null;

    // Emitted before the first await, so a caller that does not wait on this
    // still observes the reset synchronously — as it did when each cancel
    // method carried its own emit.
    if (resetState && !isClosed) {
      emit(state.copyWith(loaded: false, serverSynced: false));
    }

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    _cancelFieldSubscriptions();

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    await _disconnectionReference?.cancel();
    _disconnectionReference = null;
  }

  /* CLOSE */

  @override
  Future<void> close() {
    GamicoDatabaseShutdown.unregister(this);

    _teardown(resetState: false);

    return super.close();
  }
}
