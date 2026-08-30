import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/database_shutdown.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/features/friend/models/invitation_model.dart';
import 'package:gamico/commons/services/notification.dart';

class FriendInvitationState {
  final List<InvitationModel> pendingInvitations;
  final bool hasPendingInvitation;

  const FriendInvitationState({
    this.pendingInvitations = const [],
    this.hasPendingInvitation = false,
  });

  FriendInvitationState copyWith({
    List<InvitationModel>? pendingInvitations,
    bool? hasPendingInvitation,
  }) {
    return FriendInvitationState(
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
      hasPendingInvitation: hasPendingInvitation ?? this.hasPendingInvitation,
    );
  }
}

class FriendInvitationCubit extends Cubit<FriendInvitationState> {
  StreamSubscription? _invitationSubscription;
  // [GAMICO-FIX] Previously the onChildChanged/onChildRemoved listeners were
  // never stored, so they could never be cancelled — see listenToInvitations.
  StreamSubscription? _invitationChangedSubscription;
  StreamSubscription? _invitationRemovedSubscription;
  final Map<String, InvitationModel> _invitations = {};

  FriendInvitationCubit() : super(const FriendInvitationState()) {
    GamicoDatabaseShutdown.register(this, cancelDatabaseListeners);

    listenToInvitations();
  }

  /// See [GamicoDatabaseShutdown]: cancels every listener while the app is
  /// being torn down.
  Future<void> cancelDatabaseListeners() async {
    await _invitationSubscription?.cancel();
    _invitationSubscription = null;
    await _invitationChangedSubscription?.cancel();
    _invitationChangedSubscription = null;
    await _invitationRemovedSubscription?.cancel();
    _invitationRemovedSubscription = null;
  }

  void listenToInvitations() {
    final userId = UserService.uid;
    if (userId.isEmpty) return;
    if (GamicoDatabaseShutdown.shuttingDown) return;

    // [GAMICO-FIX] listenToInvitations() is called from BOTH the constructor and
    // on sign-in. Cancel every previous listener before re-subscribing, otherwise
    // the onChildChanged/onChildRemoved listeners (which used to be unstored)
    // stacked on each call — causing duplicated reads and duplicate invitation
    // notifications.
    _invitationSubscription?.cancel();
    _invitationChangedSubscription?.cancel();
    _invitationRemovedSubscription?.cancel();

    final invitationsRef = FirebaseDatabase.instance
        .ref()
        .child('invitations')
        .orderByChild('receiver_id')
        .equalTo(userId)
        // [GAMICO-FIX] Invitations are never purged, so onChildAdded would
        // replay the user's entire lifetime of received invitations on every
        // (re)subscribe. Bound the replay to the most recent ones (push keys are
        // chronological, so among a fixed receiver_id this is "the latest N").
        .limitToLast(30);

    // Écouter les nouvelles invitations
    _invitationSubscription = invitationsRef.onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        final invitationData = Map<String, dynamic>.from(
          event.snapshot.value as Map,
        );
        final invitation = InvitationModel.fromJson({
          ...invitationData,
          'id': event.snapshot.key!,
        });
        _invitations[event.snapshot.key!] = invitation;
        _updatePendingState();

        // Show notification if it's a new pending invitation (less than 5 minutes old)
        if (invitation.status == InvitationStatus.pending &&
            DateTime.now().difference(invitation.createdAt).inMinutes < 5) {
          NotificationService.showGameInvitationNotification(
            title: NotificationService.invitationTitle,
            body: NotificationService.invitationBody,
            invitationId: invitation.id,
          );
        } else if (invitation.status != InvitationStatus.pending) {
          // Safety net: on (re)subscribe, onChildAdded replays past invitations.
          // If one is already answered but a stale notification is still sitting
          // in the tray (app killed while it showed, or it arrived on another
          // device), drop it now.
          NotificationService.cancelGameInvitationNotification(invitation.id);
        }
      }
    }, onError: (e) => debugPrint("⚠️ _invitationSubscription error => $e"));

    // Écouter les changements de statut
    // [GAMICO-FIX] Store the subscription so it can be cancelled.
    _invitationChangedSubscription = invitationsRef.onChildChanged.listen(
      (event) {
        if (event.snapshot.value != null) {
          final invitationData = Map<String, dynamic>.from(
            event.snapshot.value as Map,
          );
          final invitation = InvitationModel.fromJson({
            ...invitationData,
            'id': event.snapshot.key!,
          });
          _invitations[event.snapshot.key!] = invitation;
          _updatePendingState();

          // Multi-device: every device signed in as the receiver gets this
          // child-changed event via the RTDB sync. When the invitation leaves
          // PENDING — because it was answered here, on another device, or
          // withdrawn by the host — drop its (now stale) tray notification on
          // this device too, without needing a server-side push.
          if (invitation.status != InvitationStatus.pending) {
            NotificationService.cancelGameInvitationNotification(invitation.id);
          }
        }
      },
      onError: (e) =>
          debugPrint("⚠️ _invitationChangedSubscription error => $e"),
    );

    // Écouter les suppressions d'invitations
    // [GAMICO-FIX] Store the subscription so it can be cancelled.
    _invitationRemovedSubscription = invitationsRef.onChildRemoved.listen(
      (event) {
        _invitations.remove(event.snapshot.key!);
        _updatePendingState();
      },
      onError: (e) =>
          debugPrint("⚠️ _invitationRemovedSubscription error => $e"),
    );
  }

  void _updatePendingState() {
    final pendingInvitations = _invitations.values
        .where((invitation) => invitation.status == InvitationStatus.pending)
        .toList();

    emit(
      FriendInvitationState(
        pendingInvitations: pendingInvitations,
        hasPendingInvitation: pendingInvitations.isNotEmpty,
      ),
    );
  }

  Future<void> updateInvitationStatus(
    String invitationId,
    InvitationStatus status,
  ) async {
    if (invitationId.trim().isEmpty) return;

    try {
      final ref = FirebaseDatabase.instance
          .ref()
          .child('invitations')
          .child(invitationId);

      await ref.update({
        'status': status.name.toUpperCase(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("⚠️ FriendInvitationCubit.updateInvitationStatus error => $e");
    }

    // The invitation just left PENDING (accepted/rejected), so its tray
    // notification — with its ACCEPT/REJECT buttons — is now stale. Drop it so
    // it can't be acted on a second time. Idempotent: cancelling an already
    // dismissed notification is a no-op.
    if (status != InvitationStatus.pending) {
      try {
        await NotificationService.cancelGameInvitationNotification(invitationId);
      } catch (e) {
        debugPrint("⚠️ FriendInvitationCubit cancelNotification error => $e");
      }
    }
  }

  @override
  Future<void> close() {
    GamicoDatabaseShutdown.unregister(this);

    // [GAMICO-FIX] Cancel all three listeners (previously only onChildAdded).
    _invitationSubscription?.cancel();
    _invitationChangedSubscription?.cancel();
    _invitationRemovedSubscription?.cancel();
    return super.close();
  }
}
