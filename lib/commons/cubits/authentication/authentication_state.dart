part of 'authentication_cubit.dart';

enum AuthenticationStateStatus { initial, loading, failure, success }

@immutable
class AuthenticationState {
  final AuthenticationStateStatus status;

  const AuthenticationState({required this.status});

  bool get authenticated => status == AuthenticationStateStatus.success;

  AuthenticationState copyWith({AuthenticationStateStatus? status}) {
    return AuthenticationState(status: status ?? this.status);
  }
}
