part of 'internet_cubit.dart';

@immutable
class InternetState {
  final bool connected;

  const InternetState({
    required this.connected,
  });

  InternetState copyWith({
    bool? connected,
  }) {
    return InternetState(
      connected: connected ?? this.connected,
    );
  }
}
