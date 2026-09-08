part of 'authentication_cubit.dart';

enum AuthenticationStateStatus { initial, loading, failure, success }

@immutable
class AuthenticationState {
  final AuthenticationStateStatus status;
  final bool authenticated;

  /// The player asked to sign out themselves, through [AuthenticationCubit.signOut].
  ///
  /// `authenticated: false` alone does NOT mean that: `authStateChanges`
  /// delivers a plain null for a deliberate sign-out, a deleted account AND a
  /// transient token-refresh failure, indistinguishably. Screens that must
  /// dismiss themselves when the account goes away — rather than wait for it
  /// to come back — key off this flag instead.
  final bool deliberateSignOut;

  const AuthenticationState({
    required this.status,
    required this.authenticated,
    this.deliberateSignOut = false,
  });

  AuthenticationState copyWith({
    AuthenticationStateStatus? status,
    bool? authenticated,
    bool? deliberateSignOut,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      authenticated: authenticated ?? this.authenticated,
      deliberateSignOut: deliberateSignOut ?? this.deliberateSignOut,
    );
  }
}
