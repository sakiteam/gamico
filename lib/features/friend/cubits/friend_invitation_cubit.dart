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
  final Map<String, InvitationModel> _invitations = {};

  FriendInvitationCubit() : super(const FriendInvitationState()) {
    listenToInvitations();
  }

  void listenToInvitations() {
    final userId = UserService.uid;
    if (userId.isEmpty) return;

    final invitationsRef = FirebaseDatabase.instance
        .ref()
        .child('invitations')
        .orderByChild('receiver_id')
        .equalTo(userId);

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
            title: 'Jeu avec un ami',
            body: 'Vous avez reçu une invitation !',
            invitationId: invitation.id,
          );
        }
      }
    });

    // Écouter les changements de statut
    invitationsRef.onChildChanged.listen((event) {
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
    invitationsRef.onChildRemoved.listen((event) {
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
    _invitationSubscription?.cancel();
    return super.close();
  }
}
