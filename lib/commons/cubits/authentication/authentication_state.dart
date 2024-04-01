part of 'authentication_cubit.dart';

enum AuthenticationStateStatus { initial, loading, failure, success }

@immutable
class AuthenticationState {
  final AuthenticationStateStatus status;
  final bool authenticated;

  const AuthenticationState({
    required this.status,
    required this.authenticated,
  });

  AuthenticationState copyWith({
    AuthenticationStateStatus? status,
    bool? authenticated,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      authenticated: authenticated ?? this.authenticated,
    );
  }
}
