import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/pass_and_play/pass_and_play_game_cubit.dart';

class PassAndPlayGamePage extends StatelessWidget {
  final Widget child;

  final void Function()? onBackButtonPressed;

  const PassAndPlayGamePage({
    super.key,
    required this.child,
    required this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GamicoPassAndPlayGameCubit, GamicoPassAndPlayGameState>(
          listener: (context, state) async {
            final gameCubit = context.read<GamicoGameCubit>();

            gameCubit.setActive(false);
            gameCubit.setAnimGame(true);

            await NavigationService.replacePageWithAnimation(
              context,
              Gamico.instance.pagesSettings.gamePage(
                context,
                GameUtility(
                  gameType: GameType.passAndPlay,
                  onBackButtonPressed: onBackButtonPressed,
                ),
              ),
            );
          },
          listenWhen: (previous, current) {
            return !previous.replayActive && current.replayActive;
          },
        ),
      ],
      child: child,
    );
  }
}
