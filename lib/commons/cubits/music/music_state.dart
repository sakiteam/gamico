part of 'music_cubit.dart';

@immutable
class GamicoMusicState {
  final bool mute;

  const GamicoMusicState({
    required this.mute,
  });

  GamicoMusicState copyWith({
    bool? mute,
  }) {
    return GamicoMusicState(
      mute: mute ?? this.mute,
    );
  }
}
