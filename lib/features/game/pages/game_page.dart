import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/pop_scope.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/adventure/adventure_game_cubit.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/local_network/local_network_game_cubit.dart';
import 'package:gamico/features/game/cubits/pass_and_play/pass_and_play_game_cubit.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/features/game/pages/adventure_game_page.dart';
import 'package:gamico/features/game/pages/local_network_game_page.dart';
import 'package:gamico/features/game/pages/pass_and_play_game_page.dart';
import 'package:gamico/features/game/pages/remote_game_page.dart';
import 'package:gamico/features/game/pages/tutorial_game_page.dart';
import 'package:gamico/features/game/widgets/game_confetti.dart';
import 'package:gamico/features/game/widgets/game_congratulations_text.dart';

/// Page on which the concrete game is played.
class GamicoGamePage extends StatelessWidget {
  final Widget child;
  final GameUtility gameUtility;

  /// Page on which the concrete game is played.
  const GamicoGamePage({
    super.key,
    required this.child,
    required this.gameUtility,
  });

  @override
  Widget build(BuildContext context) {
    final finalGameUtility = gameUtility;
    final gameType = finalGameUtility.type;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => GamicoGameCubit(
            gameType: gameType,
            userCubit: context.read<GamicoUserCubit>(),
            musicCubit: context.read<GamicoMusicCubit>(),
            characterCubit: context.read<CharacterCubit>(),
            admobCubit: context.read<AdmobCubit>(),
          ),
        ),
        if (finalGameUtility is AdventureGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoAdventureGameCubit(
              level: finalGameUtility.level,
              gameCubit: context.read<GamicoGameCubit>(),
              adventureUtility: finalGameUtility.adventureUtility,
            )..init(),
          ),
        if (finalGameUtility is TutorialGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoTutorialGameCubit(
              gameCubit: context.read<GamicoGameCubit>(),
              tutorialLessonIndex: finalGameUtility.tutorialLessonIndex,
            )..init(),
          ),
        if (finalGameUtility is RemoteGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoRemoteGameCubit(
              level: finalGameUtility.level,
              remoteUtility: finalGameUtility.remoteUtility,
              adventureUtility: finalGameUtility.adventureUtility,
              fakeOpponent: finalGameUtility.fakeOpponent,
              gameId: finalGameUtility.gameId,
              creator: finalGameUtility.creatorOfCurrentGame,
              gameCubit: context.read<GamicoGameCubit>(),
              gamesRepository: context.read<GamicoGamesRepository>(),
              friend: finalGameUtility.friend,
              replayOptions: finalGameUtility.replayOptions,
              currentReplayOption: finalGameUtility.currentReplayOption,
              replayVote: finalGameUtility.replayVote,
            )..init(),
          ),
        if (finalGameUtility is PassAndPlayGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoPassAndPlayGameCubit(
              gameCubit: context.read<GamicoGameCubit>(),
            )..init(),
          ),
        if (finalGameUtility is LocalNetworkGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoLocalNetworkGameCubit(
              gameCubit: context.read<GamicoGameCubit>(),
              userCubit: context.read<GamicoUserCubit>(),
              admobCubit: context.read<AdmobCubit>(),
              utility: finalGameUtility,
            )..init(),
          ),
      ],
      child: Builder(
        builder: (context) {
          final pageGameCubit = context.read<GamicoGameCubit>();

          // The game's own result screen, when it has one (see
          // [GameUtility.endGamePopupBuilder]). Only assigned when the utility
          // declares it, so a game that installs its own builder later — once
          // it knows what it has to draw — is not overwritten on every
          // rebuild of this page.
          if (finalGameUtility.endGamePopupBuilder != null) {
            pageGameCubit.endGamePopupBuilder =
                finalGameUtility.endGamePopupBuilder;
          }

          final finalChild = MultiBlocListener(
            listeners: [
              BlocListener<GamicoGameCubit, GamicoGameState>(
                listener: (context, state) {
                  pageGameCubit.showGamePopup(context);
                },
                listenWhen: (previous, current) {
                  return !previous.displayGamePopup && current.displayGamePopup;
                },
              ),
              BlocListener<GamicoGameCubit, GamicoGameState>(
                listener: (context, state) {
                  NavigationService.maybePop(context);
                },
                listenWhen: (previous, current) {
                  return !previous.backActive && current.backActive;
                },
              ),
              BlocListener<GamicoGameCubit, GamicoGameState>(
                listener: (context, state) {
                  pageGameCubit.handleGameOver(context);
                },
                listenWhen: (oldState, newState) {
                  return !oldState.over && newState.over;
                },
              ),
            ],
            child: GamicoPopScope(
              onWillPop: () => pageGameCubit.handleWillPop(
                context,
                onBackButtonPressed: gameUtility.onBackButtonPressed,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Concrete game
                  child,

                  // Widget that displays confettis to the user
                  const GamicoGameConfetti(),

                  // Content visible when displaying congratulation message
                  if (Gamico.instance.playSettings?.displayCongratulations ==
                      true)
                    const GamicoGameCongratulationsText(),
                ],
              ),
            ),
          );

          if (finalGameUtility is AdventureGameUtility) {
            return AdventureGamePage(
              level: finalGameUtility.level,
              onBackButtonPressed: finalGameUtility.onBackButtonPressed,
              child: finalChild,
            );
          } else if (finalGameUtility is TutorialGameUtility) {
            return TutorialGamePage(
              onBackButtonPressed: finalGameUtility.onBackButtonPressed,
              child: finalChild,
            );
          } else if (finalGameUtility is RemoteGameUtility) {
            return GamicoRemoteGamePage(
              onBackButtonPressed: finalGameUtility.onBackButtonPressed,
              endGamePopupBuilder: finalGameUtility.endGamePopupBuilder,
              child: finalChild,
            );
          } else if (finalGameUtility is LocalNetworkGameUtility) {
            return LocalNetworkGamePage(
              gameUtility: finalGameUtility,
              child: finalChild,
            );
          } else if (finalGameUtility is PassAndPlayGameUtility) {
            return PassAndPlayGamePage(
              onBackButtonPressed: finalGameUtility.onBackButtonPressed,
              child: finalChild,
            );
          }

          return finalChild;
        },
      ),
    );
  }
}
