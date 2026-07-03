import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    listenToInvitations();
  }

  void listenToInvitations() {
    final userId = UserService.uid;
    if (userId.isEmpty) return;

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
        }
      }
    });

    // Écouter les changements de statut
    // [GAMICO-FIX] Store the subscription so it can be cancelled.
    _invitationChangedSubscription = invitationsRef.onChildChanged.listen((
      event,
    ) {
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
      }
    });

    // Écouter les suppressions d'invitations
    // [GAMICO-FIX] Store the subscription so it can be cancelled.
    _invitationRemovedSubscription = invitationsRef.onChildRemoved.listen((
      event,
    ) {
      _invitations.remove(event.snapshot.key!);
      _updatePendingState();
    });
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
    final ref = FirebaseDatabase.instance
        .ref()
        .child('invitations')
        .child(invitationId);

    await ref.update({
      'status': status.name.toUpperCase(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> close() {
    // [GAMICO-FIX] Cancel all three listeners (previously only onChildAdded).
    _invitationSubscription?.cancel();
    _invitationChangedSubscription?.cancel();
    _invitationRemovedSubscription?.cancel();
    return super.close();
  }
}
