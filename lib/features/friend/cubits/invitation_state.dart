part of 'invitation_cubit.dart';

class InvitationState {
  final List<InvitationModel> pendingInvitations;
  final List<InvitationModel> sentInvitations;
  final InvitationModel? currentInvitation;
  final bool loading;
  final String? error;

  const InvitationState({
    required this.pendingInvitations,
    required this.sentInvitations,
    this.currentInvitation,
    required this.loading,
    this.error,
  });

  factory InvitationState.initial() {
    return const InvitationState(
      pendingInvitations: [],
      sentInvitations: [],
      currentInvitation: null,
      loading: false,
    );
  }

  InvitationState copyWith({
    List<InvitationModel>? pendingInvitations,
    List<InvitationModel>? sentInvitations,
    InvitationModel? currentInvitation,
    bool? loading,
    String? error,
  }) {
    return InvitationState(
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
      sentInvitations: sentInvitations ?? this.sentInvitations,
      currentInvitation: currentInvitation,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
