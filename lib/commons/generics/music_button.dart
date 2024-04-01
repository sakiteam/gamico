import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';

class GamicoMusicButton extends StatelessWidget {
  final Widget Function(
      BuildContext context, bool mute, void Function() onPressed) builder;

  const GamicoMusicButton({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final mute =
        context.select((GamicoMusicCubit musicCubit) => musicCubit.state.mute);

    return builder(
      context,
      mute,
      () {
        context.read<GamicoMusicCubit>().toggle();
      },
    );
  }
}
