part of 'music_cubit.dart';

@immutable
class GamicoMusicState {
  final bool musicMuted;
  final bool bruitagesMuted;

  const GamicoMusicState({
    required this.musicMuted,
    required this.bruitagesMuted,
  });

  /// Everything silenced — music and sound effects. What the single sound
  /// toggle of the older screens shows and flips (see [GamicoMusicCubit.toggle]).
  bool get mute => musicMuted && bruitagesMuted;

  GamicoMusicState copyWith({bool? musicMuted, bool? bruitagesMuted}) {
    return GamicoMusicState(
      musicMuted: musicMuted ?? this.musicMuted,
      bruitagesMuted: bruitagesMuted ?? this.bruitagesMuted,
    );
  }
}
