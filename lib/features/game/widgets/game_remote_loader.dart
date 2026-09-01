import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/generics/loader.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

class GamicoGameRemoteLoader extends StatelessWidget {
  const GamicoGameRemoteLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final mode =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.mode);
    final ready =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.ready);

    if (mode != GameType.remote) {
      return const SizedBox();
    }

    return const Center(child: GamicoLoader())
        .animate(target: ready ? 1 : 0)
        .fadeOut();
  }
}
