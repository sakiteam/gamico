import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/features/friend/models/invitation_model.dart';

part 'invitation_state.dart';

class InvitationCubit extends Cubit<InvitationState> {
  final FirebaseDatabase _database;
  StreamSubscription? _receivedInvitationSubscription;
  StreamSubscription? _sentInvitationSubscription;
  StreamSubscription? _currentInvitationSubscription;

  InvitationCubit(this._database) : super(InvitationState.initial());

  void startListening(String userId) {
    _receivedInvitationSubscription?.cancel();
    _sentInvitationSubscription?.cancel();

    final invitationsRef = _database.ref().child('invitations');

    // Écoute des invitations reçues
    _receivedInvitationSubscription = invitationsRef
        .orderByChild('receiver_id')
        .equalTo(userId)
        // [GAMICO-FIX] Invitations are never purged; bound the read to the most
        // recent ones (push keys are chronological) instead of the full history.
        .limitToLast(30)
        .onValue
        .listen(
          (event) {
            if (event.snapshot.value != null) {
              final Map<dynamic, dynamic> values =
                  event.snapshot.value as Map<dynamic, dynamic>;
              final invitations = values.entries
                  .map(
                    (e) => InvitationModel.fromJson({
                      ...Map<String, dynamic>.from(e.value as Map),
                      'id': e.key,
                    }),
                  )
                  .where((inv) => inv.status == InvitationStatus.pending)
                  .toList();
              emit(state.copyWith(pendingInvitations: invitations));
            } else {
              emit(state.copyWith(pendingInvitations: []));
            }
          },
          onError: (e) =>
              debugPrint("⚠️ _receivedInvitationSubscription error => $e"),
        );

    // Écoute des invitations envoyées
    _sentInvitationSubscription = _database
        .ref()
        .child('invitations')
        .orderByChild('sender_id')
        .equalTo(userId)
        // [GAMICO-FIX] Invitations are never purged; bound the read to the most
        // recent ones (push keys are chronological) instead of the full history.
        .limitToLast(30)
        .onValue
        .listen(
          (event) {
            if (event.snapshot.value != null) {
              final Map<dynamic, dynamic> values =
                  event.snapshot.value as Map<dynamic, dynamic>;
              final invitations = values.entries
                  .map(
                    (e) => InvitationModel.fromJson({
                      ...Map<String, dynamic>.from(e.value as Map),
                      'id': e.key,
                    }),
                  )
                  .toList();

              // Update sent invitations list
              emit(state.copyWith(sentInvitations: invitations));

              // If we have a current invitation, check its status
              if (state.currentInvitation != null) {
                final currentInvitation = invitations.firstWhere(
                  (inv) => inv.id == state.currentInvitation!.id,
                  orElse: () => state.currentInvitation!,
                );

                if (currentInvitation.status != InvitationStatus.pending) {
                  // Update current invitation status
                  emit(state.copyWith(currentInvitation: currentInvitation));
                }
              }
            } else {
              emit(
                state.copyWith(sentInvitations: [], currentInvitation: null),
              );
            }
          },
          onError: (e) =>
              debugPrint("⚠️ _sentInvitationSubscription error => $e"),
        );
  }

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

    await gameRef.set(
      GamicoGameModel(
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
    );
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
    await gameRef.set(
      GamicoGameModel(
        updatedAt: now,
        createdAt: now,
        status: "ACCEPTED",
        players: players,
      ).toJson(),
    );

    // Create one invitation per receiver pointing to the same game
    for (final receiverId in receiverIds) {
      final invRef = _database.ref().child('invitations').push();
      await invRef.set({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'status': 'PENDING',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
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
        'updated_at': DateTime.now().toIso8601String(),
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
    _receivedInvitationSubscription?.cancel();
    _sentInvitationSubscription?.cancel();
    _currentInvitationSubscription?.cancel();
    return super.close();
  }
}
