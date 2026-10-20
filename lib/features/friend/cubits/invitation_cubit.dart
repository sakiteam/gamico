import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/services/database_shutdown.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/features/friend/models/invitation_model.dart';

part 'invitation_state.dart';

class InvitationCubit extends Cubit<InvitationState> {
  final FirebaseDatabase _database;

  /// Three child listeners each (added/changed/removed) — see
  /// [_watchInvitations].
  List<StreamSubscription> _receivedInvitationSubscriptions = const [];
  List<StreamSubscription> _sentInvitationSubscriptions = const [];
  StreamSubscription? _currentInvitationSubscription;

  /// Live mirrors of the two query windows, keyed by invitation id. Child
  /// events patch these instead of a whole snapshot replacing them.
  final Map<String, InvitationModel> _received = {};
  final Map<String, InvitationModel> _sent = {};

  /// One per watch, coalescing a burst of child events into a single emit —
  /// see [_watchInvitations].
  final List<Timer> _notifyTimers = [];

  InvitationCubit(this._database) : super(InvitationState.initial()) {
    GamicoDatabaseShutdown.register(this, cancelDatabaseListeners);
  }

  /// See [GamicoDatabaseShutdown]: cancels every listener while the app is
  /// being torn down.
  Future<void> cancelDatabaseListeners() async {
    await _cancelInvitationSubscriptions();
    _listeningUserId = null;
    await _currentInvitationSubscription?.cancel();
    _currentInvitationSubscription = null;
  }

  Future<void> _cancelInvitationSubscriptions() async {
    for (final sub in [
      ..._receivedInvitationSubscriptions,
      ..._sentInvitationSubscriptions,
    ]) {
      await sub.cancel();
    }
    _receivedInvitationSubscriptions = const [];
    _sentInvitationSubscriptions = const [];
    for (final timer in _notifyTimers) {
      timer.cancel();
    }
    _notifyTimers.clear();
    _received.clear();
    _sent.clear();
  }

  /// Uid the two invitation listeners below are currently attached for, or null
  /// when nothing is attached. See [startListening].
  String? _listeningUserId;

  void startListening(String userId) {
    // Idempotent. Both queries below re-download their whole 30-invitation
    // window on every attach, and this is called from `initState` of a page the
    // user goes in and out of — so tearing the listeners down and rebuilding
    // them for the uid they were already watching paid for the same ~4 kB
    // again, for nothing. Re-attaching stays possible for a genuine uid change
    // (account switch), which is the only case that needs fresh data.
    if (_listeningUserId == userId &&
        _receivedInvitationSubscriptions.isNotEmpty &&
        _sentInvitationSubscriptions.isNotEmpty) {
      return;
    }

    _cancelInvitationSubscriptions();
    _listeningUserId = null;

    // An empty query fires no child event at all, where `onValue` used to
    // deliver an explicit null and clear these. Reset here so a genuine
    // (re)attach — an account switch — never leaves the previous user's
    // invitations on screen.
    if (!isClosed) {
      emit(state.copyWith(pendingInvitations: [], sentInvitations: []));
    }

    if (GamicoDatabaseShutdown.shuttingDown) return;

    _listeningUserId = userId;

    final invitationsRef = _database.ref().child('invitations');

    // Écoute des invitations reçues
    _receivedInvitationSubscriptions = _watchInvitations(
      invitationsRef
          .orderByChild('receiver_id')
          .equalTo(userId)
          // [GAMICO-FIX] Invitations are never purged; bound the read to the
          // most recent ones (push keys are chronological) instead of the full
          // history.
          .limitToLast(30),
      _received,
      label: 'received',
      onChanged: () => emit(
        state.copyWith(
          pendingInvitations: _sorted(_received)
              .where((inv) => inv.status == InvitationStatus.pending)
              .toList(),
        ),
      ),
    );

    // Écoute des invitations envoyées
    _sentInvitationSubscriptions = _watchInvitations(
      invitationsRef
          .orderByChild('sender_id')
          .equalTo(userId)
          .limitToLast(30),
      _sent,
      label: 'sent',
      onChanged: () {
        final invitations = _sorted(_sent);
        emit(state.copyWith(sentInvitations: invitations));

        final current = state.currentInvitation;
        if (current == null) return;

        // The one we are waiting on: surface its answer as soon as it lands.
        // Absent from the window (never in it, or aged out) means nothing has
        // changed about it, which is what `orElse` preserves.
        final currentInvitation = invitations.firstWhere(
          (inv) => inv.id == current.id,
          orElse: () => current,
        );

        if (currentInvitation.status != InvitationStatus.pending) {
          emit(state.copyWith(currentInvitation: currentInvitation));
        }
      },
    );
  }

  /// Keeps [into] in step with [query] and calls [onChanged] on every change.
  ///
  /// Child listeners, not `onValue`. RTDB re-sends the entire result set on
  /// every `onValue` event, so one invitation flipping to ACCEPTED used to cost
  /// all thirty in the window — twice, since the received and sent queries
  /// overlap on the invitations a player both sent and received answers for,
  /// and a third time via [FriendInvitationCubit], which watches the exact same
  /// received query with the child listeners this now mirrors. Profiling had
  /// `/invitations` at 111 kB over 54 reads, 2 kB a read, second only to
  /// `users`. The attach still replays the window once; everything after it is
  /// the one record that actually changed.
  List<StreamSubscription> _watchInvitations(
    Query query,
    Map<String, InvitationModel> into, {
    required String label,
    required VoidCallback onChanged,
  }) {
    InvitationModel? parse(DatabaseEvent event) {
      final value = event.snapshot.value;
      final key = event.snapshot.key;
      if (value is! Map || key == null) return null;
      return InvitationModel.fromJson({
        ...Map<String, dynamic>.from(value),
        'id': key,
      });
    }

    // Child events arrive one per record, and an attach replays the whole
    // window — so emitting on each would turn one `onValue` rebuild into
    // thirty. Coalesce a burst into a single emit.
    Timer? notifyTimer;
    void notify() {
      notifyTimer?.cancel();
      _notifyTimers.remove(notifyTimer);
      notifyTimer = Timer(const Duration(milliseconds: 16), () {
        _notifyTimers.remove(notifyTimer);
        if (isClosed) return;
        onChanged();
      });
      _notifyTimers.add(notifyTimer!);
    }

    void upsert(DatabaseEvent event) {
      final invitation = parse(event);
      if (invitation == null) return;
      into[invitation.id] = invitation;
      notify();
    }

    void onError(Object e) =>
        debugPrint("⚠️ _${label}InvitationSubscription error => $e");

    into.clear();

    return [
      query.onChildAdded.listen(upsert, onError: onError),
      query.onChildChanged.listen(upsert, onError: onError),
      query.onChildRemoved.listen((event) {
        final key = event.snapshot.key;
        if (key == null || into.remove(key) == null) return;
        notify();
      }, onError: onError),
    ];
  }

  /// Push keys are chronological, so ordering by id reproduces the order the
  /// `onValue` snapshot used to arrive in.
  static List<InvitationModel> _sorted(Map<String, InvitationModel> byId) =>
      byId.values.toList()..sort((a, b) => a.id.compareTo(b.id));

  Future<InvitationModel> sendInvitation(
    String receiverId,
    String senderId,
  ) async {
    // Check if we already have a pending invitation
    if (state.currentInvitation != null) {
      throw Exception('Already have a pending invitation');
    }

    final now = DateTime.now();

    final newInvitationRef = _database.ref().child('invitations').push();
    final invitation = InvitationModel(
      id: newInvitationRef.key!,
      senderId: senderId,
      receiverId: receiverId,
      status: InvitationStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    final gameRef = _database.ref().child('games').child(newInvitationRef.key!);

    final ref = FirebaseDatabase.instance.ref();

    final key1 = ref.push().key ?? "";
    final key2 = ref.push().key ?? "";

    await gameRef.set({
      ...GamicoGameModel(
        updatedAt: now,
        createdAt: now,
        status: "ACCEPTED",
        players: {
          key1: GamicoGamePlayerModel(
            createdAt: now,
            updatedAt: now,
            status: "ACCEPTED",
            userId: senderId,
          ),
          key2: GamicoGamePlayerModel(
            createdAt: now,
            updatedAt: now,
            status: "ACCEPTED",
            userId: receiverId,
          ),
        },
      ).toJson(),
      'last_activity_at': ServerValue.timestamp,
    });
    await newInvitationRef.set(invitation.toJson());

    // Set this as our current invitation and start listening to it
    emit(state.copyWith(currentInvitation: invitation));
    _listenToCurrentInvitation(invitation.id);

    return invitation;
  }

  /// Creates a multi-player friendly game with all players pre-joined and sends
  /// invitations to each receiver. The host navigates directly as creator.
  /// Returns the shared game ID that all players will join.
  Future<String> sendMultiInvitations({
    required String senderId,
    required List<String> receiverIds,
    required String mode,
    required int maxPlayers,
  }) async {
    final now = DateTime.now();

    // Build players map: host + all receivers pre-added
    final Map<String, GamicoGamePlayerModel> players = {};
    final hostKey = _database.ref().push().key ?? "";
    players[hostKey] = GamicoGamePlayerModel(
      createdAt: now,
      updatedAt: now,
      status: "ACCEPTED",
      userId: senderId,
    );
    for (final receiverId in receiverIds) {
      final playerKey = _database.ref().push().key ?? "";
      players[playerKey] = GamicoGamePlayerModel(
        createdAt: now,
        updatedAt: now,
        status: "ACCEPTED",
        userId: receiverId,
      );
    }

    // Create the shared game
    final gameRef = _database.ref().child('games').push();
    final gameId = gameRef.key!;
    await gameRef.set({
      ...GamicoGameModel(
        updatedAt: now,
        createdAt: now,
        status: "ACCEPTED",
        players: players,
      ).toJson(),
      'last_activity_at': ServerValue.timestamp,
    });

    // Create one invitation per receiver pointing to the same game
    for (final receiverId in receiverIds) {
      final invRef = _database.ref().child('invitations').push();
      await invRef.set({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'status': 'PENDING',
        // UTC with its `Z`, see InvitationModel.toJson.
        'created_at': now.toUtc().toIso8601String(),
        'updated_at': now.toUtc().toIso8601String(),
        'settings': {
          'mode': mode,
          'max_players': maxPlayers,
          'game_id': gameId,
        },
      });
    }

    return gameId;
  }

  Future<void> updateInvitationStatus(
    String invitationId,
    InvitationStatus status,
  ) async {
    if (invitationId.trim().isEmpty) return;

    try {
      final ref = _database.ref().child('invitations').child(invitationId);

      await ref.update({
        'status': status.name.toUpperCase(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint("⚠️ InvitationCubit.updateInvitationStatus error => $e");
    }

    // The invitation just left PENDING (accepted/rejected), so its tray
    // notification — with its ACCEPT/REJECT buttons — is now stale. Drop it so
    // it can't be acted on a second time. Idempotent: cancelling an already
    // dismissed notification is a no-op.
    if (status != InvitationStatus.pending) {
      try {
        await NotificationService.cancelGameInvitationNotification(invitationId);
      } catch (e) {
        debugPrint("⚠️ InvitationCubit cancelNotification error => $e");
      }
    }
  }

  void nullifyCurrentInvitation() {
    _currentInvitationSubscription?.cancel();
    _currentInvitationSubscription = null;

    emit(state.copyWith(currentInvitation: null));
  }

  void cancelCurrentInvitation() async {
    if (state.currentInvitation != null) {
      await updateInvitationStatus(
        state.currentInvitation!.id,
        InvitationStatus.rejected,
      );

      nullifyCurrentInvitation();
    }
  }

  void _listenToCurrentInvitation(String invitationId) {
    _currentInvitationSubscription?.cancel();

    _currentInvitationSubscription = _database
        .ref()
        .child('invitations')
        .child(invitationId)
        .onValue
        .listen(
          (event) {
            if (event.snapshot.value != null) {
              final data = Map<String, dynamic>.from(
                event.snapshot.value as Map,
              );
              final invitation = InvitationModel.fromJson({
                ...data,
                'id': invitationId,
              });

              if (invitation.status != InvitationStatus.pending) {
                // Update current invitation status
                emit(state.copyWith(currentInvitation: invitation));
                // Stop listening since the invitation is no longer pending
                _currentInvitationSubscription?.cancel();
                _currentInvitationSubscription = null;
              }
            }
          },
          onError: (e) =>
              debugPrint("⚠️ _currentInvitationSubscription error => $e"),
        );
  }

  @override
  Future<void> close() {
    GamicoDatabaseShutdown.unregister(this);

    _cancelInvitationSubscriptions();
    _currentInvitationSubscription?.cancel();
    return super.close();
  }
}
