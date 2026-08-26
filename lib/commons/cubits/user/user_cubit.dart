import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remove_diacritic/remove_diacritic.dart';
// import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:gamico/commons/services/gratification.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';

part 'user_state.dart';

/// Outcome of a player-initiated rename (see [GamicoUserCubit.updateUserName]).
enum GamicoNameUpdateResult {
  success,

  /// Empty, too short/long, or contains forbidden characters.
  invalid,

  /// Another account already uses this name.
  taken,

  /// No signed-in account to rename.
  unauthenticated,

  /// The write (or the uniqueness check) could not be completed.
  failure,
}

class GamicoUserCubit extends Cubit<GamicoUserState> {
  // UserCubit({
  //   required super.usersRepository,
  // });

  GamicoUserCubit({
    required this.usersRepository,
    // required this.fromJson,
    // required this.toJson,
  }) : super(GamicoUserState(user: UserService.getUser())) {
    // if (UserService.authenticated) {
    //   listenToUserChanges();
    // }
  }

  // final dynamic Function(Map<String, dynamic>) fromJson;
  // final Map<String, dynamic> Function(dynamic) toJson;

  bool _managed = false;
  GamicoUsersRepository usersRepository;
  StreamSubscription? _streamSubscription;
  StreamSubscription<DatabaseEvent>? _disconnectionSubscription;
  OnDisconnect? _disconnectionReference;
  // Timer? _pendingSignOutTimer;

  void _manageDisconnection() {
    // Never operate on an empty uid: `ref("users/")` resolves to the `users`
    // collection ROOT, and writing online/updated_at there corrupts the shared
    // user store. (Mirrors the guard already in Ludiko's connecto UserCubit.)
    if (UserService.uid.isEmpty) return;

    _managed = true;

    final ref = FirebaseDatabase.instance.ref("users/${UserService.uid}");

    _disconnectionSubscription = FirebaseDatabase.instance
        .ref(".info/connected")
        .onValue
        .listen((event) {
          final online = event.snapshot.value as bool? ?? false;

          if (online) {
            final user = state.user;
            final isUserComplete =
                user != null &&
                (user.socialId != null ||
                    user.firebaseId != null ||
                    user.name != null);

            if (state.loaded && isUserComplete) {
              final now = DateTime.now();

              _disconnectionReference = ref.onDisconnect();

              _disconnectionReference?.update({
                "online": false,
                "updated_at": "$now",
              });

              ref.update({"online": true, "updated_at": "$now"});
            } else {
              debugPrint(
                "⚠️ [UserCubit] Connexion détectée mais l'utilisateur n'est pas "
                "complètement chargé. Mise à jour de présence ignorée.",
              );
            }
          }
        });
  }

  bool isAchivementUnlocked(String id) {
    final achievements = state.user?.achievements ?? {};
    return (achievements[id] ?? 0) == 100;
  }

  void unlockAchievement(String id, [double percentage = 100, int steps = 0]) {
    if (UserService.authenticated) {
      if (!isAchivementUnlocked(id)) {
        () async {
          await GamicoGlobalService.waitWhile(
            () => !PlayService.gameServicesEnabled,
          );

          Achievements.unlock(
            achievement: Achievement(
              androidID: id,
              iOSID: id,
              percentComplete: percentage,
              steps: steps,
            ),
          );
        }();

        FirebaseDatabase.instance
            .ref("users/${UserService.uid}/achievements/$id")
            .set(percentage);

        if (percentage == 100) {
          incrementCowries(3);
        }
      }
    }
  }

  void incrementLevel() {
    if (UserService.uid.isEmpty) return;
    usersRepository.incrementUserLevel(UserService.uid);
  }

  void updateUserLevel(int level) {
    if (UserService.uid.isEmpty) return;

    // [GAMICO-FIX] name/level-loss investigation.
    // Guard + instrumentation: a level is written as an ABSOLUTE value, and the
    // level getters default to 1 when the user isn't loaded. So writing while
    // `state.user` is null — or writing a value below the known level — is how
    // a real progression gets clobbered down to 1. Refuse both and log the
    // culprit (value + whether the user was null + call stack).
    final current = state.user?.level;
    if (state.user == null || level < (current ?? 0)) {
      debugPrint(
        "⚠️ updateUserLevel($level) BLOCKED "
        "userNull=${state.user == null} currentLevel=$current\n"
        "${StackTrace.current}",
      );
      return;
    }

    usersRepository.updateUserLevel(UserService.uid, level);
  }

  void updateStars(List<int> stars) {
    if (UserService.uid.isEmpty) return;
    usersRepository.updateUserStars(UserService.uid, stars);
  }

  void incrementVictories() async {
    if (UserService.uid.isEmpty) return;
    final finalCrowns = (state.user?.trophies ?? 0) + 1;
    await usersRepository.incrementUserTrophies(UserService.uid);
    await _submitTacticiansScore(finalCrowns);
  }

  void incrementDefeats() async {
    if (UserService.uid.isEmpty) return;
    final finalCrowns = (state.user?.trophies ?? 0) - 1;

    await usersRepository.decrementUserTrophies(
      UserService.uid,
      finalCrowns >= 0 ? 1 : 0,
    );

    if (finalCrowns >= 0) {
      await _submitTacticiansScore(finalCrowns);
    }
  }

  Future<void> incrementCowries([int cowries = 1]) async {
    if (UserService.uid.isEmpty) return;
    // Show that diamonds are increasing
    emit(
      state.copyWith(
        cowriesUpdate: state.cowriesUpdate + 1,
        cowriesUpdateDifference: cowries,
      ),
    );

    // Get user final diamonds
    final finalDiamonds = (state.user?.coins ?? 0) + cowries;

    // Increment user diamonds really
    await usersRepository.incrementUserCoins(UserService.uid, cowries);

    // Submit score to leaderboards
    await _submitCollectorsScore(finalDiamonds);
  }

  Future<void> decrementCowries([int cowries = 1]) async {
    if (UserService.uid.isEmpty) return;
    final userDiamonds = (state.user?.coins ?? 0);
    final cowriesToDecrement = min(cowries, userDiamonds);

    if (cowriesToDecrement == 0) return;

    // Show that diamonds are decreasing
    emit(
      state.copyWith(
        cowriesUpdate: state.cowriesUpdate + 1,
        cowriesUpdateDifference: -cowriesToDecrement,
      ),
    );

    // Decrement user diamonds really
    await usersRepository.decrementUserCoins(
      UserService.uid,
      cowriesToDecrement,
    );

    // Submit score to leaderboards
    await _submitCollectorsScore(max(userDiamonds - cowries, 0));
  }

  /// Emits a signal distinct from [incrementCowries]'s `cowriesUpdate` so a
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
    if (UserService.uid.isEmpty) return;

    // [GAMICO-FIX] name/level-loss investigation.
    // Guard + instrumentation: callers build `progression` by merging onto the
    // current `state.user.progression`. If `state.user` is null they merge onto
    // an empty map, so this write would overwrite EVERY game's progression with
    // a near-empty one. Refuse when the user isn't loaded and log the culprit.
    if (state.user == null) {
      debugPrint(
        "⚠️ updateUserProgression BLOCKED (user not loaded) "
        "progression=$progression\n${StackTrace.current}",
      );
      return;
    }

    // Optimistically update the local state to prevent read-modify-write
    // race conditions when multiple updates are fired synchronously
    // (e.g. setUserStars followed immediately by setUserLevel).
    final updatedUser = Gamico.instance.userFromJson(
      state.user!.toJson()..["progression"] = progression,
    );
    emit(state.copyWith(user: () => updatedUser));

    usersRepository.updateUserProgression(UserService.uid, progression);
  }

  void updateUserSkins(Map<String, dynamic> skins) {
    if (UserService.uid.isEmpty) return;
    usersRepository.updateUserSkins(UserService.uid, skins);
  }

  void setPremium() {
    if (UserService.uid.isEmpty) return;
    usersRepository.updateUserPremium(UserService.uid, true);
  }

  Future<void> _submitCollectorsScore(int score) async {
    await GamicoGlobalService.waitWhile(() => !PlayService.gameServicesEnabled);

    if ((Gamico.instance.playSettings?.inactivePlayersLeaderboardId ?? "")
        .isEmpty) {
      return;
    }

    await Leaderboards.submitScore(
      score: Score(
        androidLeaderboardID:
            Gamico.instance.playSettings?.inactivePlayersLeaderboardId ?? "",
        iOSLeaderboardID:
            Gamico.instance.playSettings?.inactivePlayersLeaderboardId ?? "",
        value: score,
      ),
    );
  }

  Future<void> _submitTacticiansScore(int score) async {
    await GamicoGlobalService.waitWhile(() => !PlayService.gameServicesEnabled);

    if ((Gamico.instance.playSettings?.activePlayersLeaderboardId ?? "")
        .isEmpty) {
      return;
    }

    await Leaderboards.submitScore(
      score: Score(
        androidLeaderboardID:
            Gamico.instance.playSettings?.activePlayersLeaderboardId ?? "",
        iOSLeaderboardID:
            Gamico.instance.playSettings?.activePlayersLeaderboardId ?? "",
        value: score,
      ),
    );
  }

  // dynamic?
  void setUser(dynamic user, {bool loaded = false}) {
    // [GAMICO-FIX] name/level-loss investigation.
    // Instrumentation: clearing a previously-loaded user also wipes the
    // persisted local copy (UserService.setUser(null) below), which is what
    // makes a name/level "disappear". Log it so it can be correlated with the
    // auth event that triggered it.
    if (user == null && state.user != null) {
      debugPrint(
        "⚠️ setUser(null) clearing loaded user\n${StackTrace.current}",
      );
    }

    emit(state.copyWith(user: () => user, loaded: loaded));

    UserService.setUser(user);
  }

  // Names
  //
  // Two distinct names live on a user:
  //  * `social_name` mirrors the Game Center / Play Games display name. It is
  //    refreshed on every sign-in and the player cannot change it from here.
  //  * `name` is what the game shows everywhere. It is seeded from the social
  //    name the first time the account is seen, then belongs to the player:
  //    the platform must never overwrite it again.
  //
  // `formatted_name` is the normalized mirror of `name` (lowercased, no
  // diacritics). It backs the friend search AND the uniqueness check, so both
  // are always written together.

  static const int nameMinLength = 5;
  static const int nameMaxLength = 15;

  /// RTDB never fails a write while offline, it just keeps it pending. Cap the
  /// wait so a rename can be reported as failed instead of hanging.
  static const Duration _writeTimeout = Duration(seconds: 10);

  /// Letters (any alphabet), digits, spaces and a few separators.
  static final RegExp _nameAllowedCharacters = RegExp(
    r"^[\p{L}\p{N} ._'-]+$",
    unicode: true,
  );

  /// Trims and collapses whitespace. What actually gets stored in `name`.
  static String sanitizeName(String name) =>
      name.trim().replaceAll(RegExp(r"\s+"), " ");

  /// Drops unpaired UTF-16 surrogates.
  ///
  /// Some accounts' `name` was seeded before [_findAvailableName] truncated
  /// by grapheme cluster instead of code unit, so a handful of stored names
  /// still contain a lone surrogate. Flutter's TextPainter throws on that
  /// (`string is not well-formed UTF-16`) the moment the value is laid out in
  /// an editable field, so strip it defensively wherever a stored name feeds
  /// a TextField, not just at write time.
  static String stripLoneSurrogates(String name) {
    final buffer = StringBuffer();

    for (var i = 0; i < name.length; i++) {
      final unit = name.codeUnitAt(i);

      if (unit >= 0xD800 && unit <= 0xDBFF) {
        final hasLowSurrogate = i + 1 < name.length &&
            name.codeUnitAt(i + 1) >= 0xDC00 &&
            name.codeUnitAt(i + 1) <= 0xDFFF;

        if (!hasLowSurrogate) continue;

        buffer.write(name[i]);
        buffer.write(name[i + 1]);
        i++;
      } else if (unit >= 0xDC00 && unit <= 0xDFFF) {
        continue;
      } else {
        buffer.write(name[i]);
      }
    }

    return buffer.toString();
  }

  /// Normalized form stored in `formatted_name`.
  static String formatName(String name) =>
      removeDiacritics(sanitizeName(name).toLowerCase());

  static bool isNameValid(String name) {
    final sanitized = sanitizeName(name);

    return sanitized.length >= nameMinLength &&
        sanitized.length <= nameMaxLength &&
        _nameAllowedCharacters.hasMatch(sanitized);
  }

  /// Whether [formattedName] already belongs to ANOTHER account.
  ///
  /// Returns null when the check itself failed (offline, permission, …) so the
  /// caller can refuse the rename instead of silently creating a duplicate.
  Future<bool?> isNameTaken(String formattedName) async {
    if (formattedName.isEmpty) return null;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child("users")
          .orderByChild("formatted_name")
          .equalTo(formattedName)
          // One extra entry so our own account never hides a real conflict.
          .limitToFirst(2)
          .get()
          .timeout(_writeTimeout);

      if (!snapshot.exists) return false;

      final data = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(snapshot.value)),
      );

      return data.keys.any((id) => id != UserService.uid);
    } catch (e) {
      debugPrint("⚠️ isNameTaken('$formattedName') failed: $e");
      return null;
    }
  }

  /// Derives a free name from [base] by suffixing a number when needed. Used
  /// for the initial seeding only — a player-initiated rename must fail loudly
  /// rather than silently rename someone to "Alex2".
  Future<String> _findAvailableName(String base) async {
    var root = sanitizeName(base);

    if (!isNameValid(root)) {
      root = sanitizeName(GamicoGlobalService.getRandomPlayerName());
    }

    for (var attempt = 0; attempt < 8; attempt++) {
      final suffix = attempt == 0
          ? ""
          : "${GamicoGlobalService.random.nextInt(900) + 100}";

      // Keep room for the suffix rather than overflowing the max length.
      // Truncate by grapheme cluster, not UTF-16 code unit: root can contain
      // astral-plane letters (e.g. some non-Latin scripts), and cutting mid
      // surrogate pair leaves a lone surrogate that later crashes any
      // TextField laid out with this name (invalid UTF-16 in TextPainter).
      final trimmed = root.length + suffix.length > nameMaxLength
          ? root.characters
                .take(nameMaxLength - suffix.length)
                .toString()
          : root;

      final candidate = "$trimmed$suffix";

      if (await isNameTaken(formatName(candidate)) == false) return candidate;
    }

    return root;
  }

  /// Called by the Game Center / Play Games player stream.
  ///
  /// Always refreshes `social_name`, and seeds `name` only while the player
  /// has none — after that the platform name is purely informative.
  bool get _canWriteUser =>
      UserService.authenticated &&
      UserService.uid.isNotEmpty &&
      state.loaded &&
      state.user != null;

  void setUserSocialName(String name) async {
    final sanitized = sanitizeName(name);

    if (sanitized.isEmpty) return;

    // The game services stream usually fires before the account finished
    // loading, and writing then would keep a ghost node alive (see
    // manageUserChanges). Wait for a real user — but give up instead of
    // looping forever when the sign-in never completes.
    for (var attempt = 0; attempt < 40 && !_canWriteUser; attempt++) {
      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (!_canWriteUser) return;

    final user = state.user!;

    if (user.socialName != sanitized) {
      // Best-effort: `social_name` is informative, a failure must not block
      // the seeding below.
      usersRepository
          .updateUserSocialName(UserService.uid, sanitized)
          .catchError((e) => debugPrint("⚠️ updateUserSocialName failed: $e"));
    }

    if (sanitizeName(user.name ?? "").isNotEmpty) return;

    final seed = await _findAvailableName(sanitized);

    debugPrint("ℹ️ seeding name from game services: '$seed'");

    await _writeName(seed);
  }

  /// Called right after a brand-new account is created: its `name` was
  /// resolved locally (game services display name, or a random one) without
  /// knowing what the other players use. Make it unique before it shows up in
  /// a lobby.
  Future<void> ensureUniqueName() async {
    if (UserService.uid.isEmpty) return;

    final current = sanitizeName(state.user?.name ?? "");

    if (current.isEmpty) return;
    if (await isNameTaken(formatName(current)) != true) return;

    final available = await _findAvailableName(current);

    debugPrint("ℹ️ '$current' already taken, falling back to '$available'");

    await _writeName(available);
  }

  /// Player-initiated rename. Only touches `name`/`formatted_name`.
  Future<GamicoNameUpdateResult> updateUserName(String name) async {
    if (!UserService.authenticated || UserService.uid.isEmpty) {
      return GamicoNameUpdateResult.unauthenticated;
    }

    final sanitized = sanitizeName(name);

    if (!isNameValid(sanitized)) return GamicoNameUpdateResult.invalid;

    // Same name (possibly re-cased): nothing to check, nothing to conflict on.
    if (sanitized == sanitizeName(state.user?.name ?? "")) {
      return GamicoNameUpdateResult.success;
    }

    final formatted = formatName(sanitized);
    final taken = await isNameTaken(formatted);

    if (taken == null) return GamicoNameUpdateResult.failure;
    if (taken) return GamicoNameUpdateResult.taken;

    return await _writeName(sanitized)
        ? GamicoNameUpdateResult.success
        : GamicoNameUpdateResult.failure;
  }

  /// Writes the name to the SERVER and reports whether it actually landed.
  ///
  /// A name that only changed locally would break every player looking this
  /// one up, so the caller must be able to tell the player it failed. RTDB
  /// keeps a write pending forever while offline instead of failing, hence the
  /// explicit timeout.
  Future<bool> _writeName(String name) async {
    try {
      await usersRepository
          .updateUserName(UserService.uid, name, formatName(name))
          .timeout(_writeTimeout);
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

  void setUserToken(String? token) async {
    if (token == null) return;

    if (!UserService.authenticated) return;
    if (FirebaseAuth.instance.currentUser == null) return;

    await usersRepository.updateUserToken(UserService.uid, token);
  }

  void setUserPhoto(String? photo) {
    //
    // final photo = ;
    if (photo != null && photo != state.user?.photo) {
      usersRepository.updateUserPhoto(UserService.uid, photo);
    }
  }

  Future<void> saveToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        if (apnsToken == null) {
          await Future.delayed(const Duration(minutes: 1));
          saveToken();
          return;
        }
      }

      setUserToken(await FirebaseMessaging.instance.getToken());
      FirebaseMessaging.instance.onTokenRefresh.listen(setUserToken);
    } catch (e) {
      debugPrint("$e");
    }
  }

  void listenToUserChanges() async {
    _streamSubscription?.cancel();

    if (!UserService.authenticated) return;

    final ref = FirebaseDatabase.instance.ref("users/${UserService.uid}");

    // await ref.keepSynced(false);

    // [DIAG] `.get()` returned only {updated_at} (cached optimistic value)
    // without throwing -> the SDK likely could NOT reach the RTDB backend and
    // fell back to cache. Confirm the actual connection state + the URL used,
    // and force the socket online in case a stray goOffline() left it down.
    // debugPrint("🔎 databaseURL => ${FirebaseDatabase.instance.databaseURL}");
    // await FirebaseDatabase.instance.goOnline();
    // FirebaseDatabase.instance.ref(".info/connected").onValue.listen((event) {
    //   final online = event.snapshot.value as bool? ?? false;

    //   print(online);
    // });

    // // print(a);
    // // .then((s) => print("🔎 .info/connected => ${s}")).onError((e, stack) {
    // //   print("AAA $e $stack");
    // // });

    // ref
    //     .get()
    //     .then(
    //       (snap) =>
    //           debugPrint("🔎 users/${UserService.uid} .get() => ${snap.value}"),
    //     )
    //     .catchError(
    //       (e) => debugPrint("⚠️ users/${UserService.uid} .get() ERROR => $e"),
    //     );

    _streamSubscription = ref.onValue.listen(
      manageUserChanges,
      onError: (e) =>
          debugPrint("⚠️ users/${UserService.uid} onValue ERROR => $e"),
    );
  }

  void manageUserChanges(DatabaseEvent event) async {
    if (event.snapshot.value != null) {
      final json = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(event.snapshot.value)),
      );

      // print("OKOK $value");
      // A real value arrived: cancel any pending sign-out scheduled by a
      // previous (transient) null event.
      // _pendingSignOutTimer?.cancel();
      // _pendingSignOutTimer = null;

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
            "users/${UserService.uid}: ${event.snapshot.value}",
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

      if (value == null) return;

      setUser(value, loaded: true);

      if (!_managed) {
        _manageDisconnection();
      }
    }
    // else {
    // setUser(null);

    // if (!await SimpleConnectionChecker.isConnectedToInternet()) return;

    // final uid = UserService.uid;
    // if (uid.isEmpty) return;

    // try {
    //   final snapshot = await FirebaseDatabase.instance
    //       .ref("users/$uid")
    //       .get();

    //   if (snapshot.exists && snapshot.value != null) {
    //     // False alarm: the node is still there. Resync the user so the UI
    //     // reflects the real value (the listener may stay stale on null).
    //     final value = Gamico.instance.userFromJson(
    //       jsonDecode(jsonEncode(snapshot.value)),
    //     );

    //     if (value != null && value.name != null) {
    //       setUser(value);
    //     }

    //     return;
    //   }
    // } catch (_) {
    //   // Could not confirm deletion (e.g. permission/transient error) —
    //   // err on the safe side and keep the user signed in.
    //   return;
    // }

    // await FirebaseAuth.instance.signOut();
    // }
  }

  void cancelUserChangesListener() {
    _managed = false;
    _streamSubscription?.cancel();
    _disconnectionSubscription?.cancel();
    _disconnectionReference?.cancel();
    emit(state.copyWith(loaded: false));
  }

  Future<void> updateUserGratification(
    int lastGratificationDiamonds,
    int nextGratificationDiamonds,
  ) async {
    incrementCowries(lastGratificationDiamonds);

    // print(state.user?.toJson());
    // print("---");

    usersRepository.updateUserGratification(
      UserService.uid,
      lastGratificationDiamonds,
      nextGratificationDiamonds,
    );

    GratificationService.gratifiedAt = DateTime.now();

    // print(state.user?.toJson());

    // forceLastGratificationDate();
  }

  // void forceLastGratificationDate() {
  //   if (state.user != null) {
  //     final json = state.user!.toJson();
  //     json["gratified_at"] = DateTime.now().toString();
  //     emit(state.copyWith(
  //       user: T.fromJson(json),
  //     ));
  //   }
  // }

  @override
  void onChange(Change<GamicoUserState> change) {
    final oldUser = change.currentState.user;
    final newUser = change.nextState.user;

    if (newUser != null && oldUser == null) {
      listenToUserChanges();
    } else if (newUser == null && oldUser != null) {
      cancelUserChangesListener();
    }

    super.onChange(change);
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    _disconnectionSubscription?.cancel();
    _disconnectionReference?.cancel();

    return super.close();
  }

  /// Pass the tutorial
  // unlockBeginnerAchievement() {
  //   unlockAchievement(AchievementType.beginner.id);
  // }

  ///////////////////////

  // void setCards(Map<String, int>? cards) {
  //   usersRepository.setCards(UserService.uid, cards);
  // }

  // void setDecks(List<List<String>>? decks) {
  //   usersRepository.setDecks(UserService.uid, decks);
  // }

  // void setActiveDeck(int activeDeck) {
  //   usersRepository.setActiveDeck(UserService.uid, activeDeck);
  // }

  // void upgradeCard(String cardId) {
  //   final cards = state.user?.cards ?? {};
  //   final currentLevel = (cards[cardId] ?? 0);
  //   cards[cardId] = currentLevel + 1;
  //   decrementCowries(currentLevel * 10);
  //   setCards(cards);
  // }

  // void deleteCard(String cardId) {
  //   final activeDeck = state.user?.activeDeck ?? 0;
  //   List<List<String>> decks = state.user?.decks ?? [];
  //   decks += List.filled(3 - decks.length, List.filled(8, ""));
  //   final currentDeck = decks[activeDeck];
  //   final currentCardIndex = currentDeck.indexOf(cardId);
  //   currentDeck[currentCardIndex] = "";
  //   setDecks(decks);
  // }

  // void useCard(CardUtility card) {
  //   final activeDeck = state.user?.activeDeck ?? 0;
  //   List<List<String>> decks = state.user?.decks ?? [];
  //   decks += List.filled(3 - decks.length, List.filled(8, ""));
  //   final currentDeck = decks[activeDeck];
  //   for (int i = 0; i < currentDeck.length; i++) {
  //     if (currentDeck[i].isEmpty) {
  //       currentDeck[i] = card.type.id;
  //       break;
  //     }
  //   }
  //   setDecks(decks);
  // }

  // void acquireCard(CardUtility card) {
  //   final cards = state.user?.cards ?? {};
  //   cards[card.type.id] = 1;
  //   decrementCowries(card.cost);
  //   setCards(cards);
  // }
}
