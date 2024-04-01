part of 'showcase_cubit.dart';

class ShowcaseState {
  final bool active;

  const ShowcaseState({
    this.active = false,
  });

  ShowcaseState copyWith({
    bool? active,
  }) {
    return ShowcaseState(
      active: active ?? this.active,
    );
  }
}
