import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/pop_scope.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/adventure_utility.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';

class GamicoRemotePage extends StatefulWidget {
  final Widget child;
  final RemoteUtility remoteUtility;
  final AdventureUtility? adventureGameUtility;
  final int? level;
  final String? senderId;
  final String? receiverId;

  const GamicoRemotePage({
    super.key,
    required this.child,
    required this.remoteUtility,
    required this.adventureGameUtility,
    required this.level,
    this.receiverId,
    this.senderId,
  });

  @override
  State<GamicoRemotePage> createState() => _GamicoRemotePageState();
}

class _GamicoRemotePageState extends State<GamicoRemotePage> {
  late final RemoteCubit remoteCubit;

  /// The match whose table this page has already opened.
  ///
  /// The launch used to be a one-shot `listenWhen` on the `success`
  /// transition, additionally gated on [RemoteState.enabled] (an animation
  /// flag). A player whose flag happened to be down at that exact instant —
  /// `animGame` left up by a previous launch, `animInit` taken down by a back
  /// press whose pop never completed — was matched, seated in
  /// `games/<id>/players` and then simply never taken to the table: the
  /// matchmaking screen stayed up for good while the opponents burned the
  /// readiness grace waiting on a player whose device had already given up on
  /// showing them the game.
  ///
  /// The launch is now driven by the state alone, and keyed by the game it
  /// launches: every `success` state is a chance to open the table, each match
  /// opens exactly once, and a rematch (a brand-new game id) opens again.
  String? _pushedMatchKey;

  /// Key identifying the match carried by [state]: the game id, or the search
  /// generation for the (unexpected) case of a success without one.
  String _matchKeyOf(RemoteState state) => state.gameId.isNotEmpty
      ? state.gameId
      : "search-${state.searchGeneration}";

  @override
  void initState() {
    super.initState();

    remoteCubit = RemoteCubit(
      userCubit: context.read<GamicoUserCubit>(),
      gamesRepository: context.read<GamicoGamesRepository>(),
      remoteUtility: widget.remoteUtility,
      level: widget.level,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      remoteCubit.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocProvider(
      // lazy: false,
      create: (context) => remoteCubit,
      // RemoteCubit(
      //   userCubit: context.read<GamicoUserCubit>(),
      //   gamesRepository: context.read<GamicoGamesRepository>(),
      // )..init()
      child: MultiBlocListener(
        listeners: [
          BlocListener<RemoteCubit, RemoteState>(
            listener: (context, state) {
              if (Gamico.instance.playSettings?.exitUserWhenDisconnected ==
                      true ||
                  !state.fakeOpponent) {
                NavigationService.showPopup(
                  context: context,
                  builder: (_) {
                    return GamicoPopup(
                      child: GamicoDialogPoster(
                        icon: Icons.wifi_off,
                        title: l.remoteConnexionProblemTitle,
                        description: l.remoteConnexionProblemDescription,
                        simple: true,
                        onAccepted: () {
                          context.read<RemoteCubit>().setInternetError(false);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                );
              }
            },
            listenWhen: (previous, current) {
              return !previous.internetError && current.internetError;
            },
          ),
          BlocListener<RemoteCubit, RemoteState>(
            listener: (context, remoteState) async {
              final remoteCubit = context.read<RemoteCubit>();

              // Resolved to the pool the game actually came from, so a "no
              // preference" search hands the game its real mode.
              final remoteUtility = remoteCubit.matchedRemoteUtility;

              final matchKey = _matchKeyOf(remoteState);

              if (_pushedMatchKey != matchKey) {
                _pushedMatchKey = matchKey;

                remoteCubit.setAnimGame(true);
                remoteCubit.setAnimated(true);

                NavigationService.closePopups();

                try {
                  await NavigationService.pushPageWithAnimation(
                    context,
                    BlocProvider.value(
                      value: remoteCubit,
                      child: Gamico.instance.pagesSettings.gamePage(
                        context,
                        RemoteGameUtility(
                          level: remoteState.level,
                          gameId: remoteState.gameId,
                          fakeOpponent: remoteState.fakeOpponent,
                          remoteUtility: remoteUtility,
                          adventureUtility: widget.adventureGameUtility,
                          creatorOfCurrentGame: remoteState.creator ?? false,
                          onBackButtonPressed: () async {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!context.mounted) return;
                              if (widget.remoteUtility.adventure) {
                                remoteCubit.setForcePop(true);
                                NavigationService.pop(context);
                              } else {
                                // Pop the matchmaking page too: the user should
                                // return to wherever they came from, not get stuck
                                // on the "finding opponent" screen.
                                final nav = Navigator.maybeOf(context);
                                nav?.pop();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  );

                  // The push above completes when the game page is popped: the
                  // player is looking at this waiting screen again (a rematch
                  // search, or a genuine exit whose own pop is on its way).
                  // `animGame` has to come back down with it — it used to stay
                  // up for the life of the page, and with it `enabled` stayed
                  // false, which is one of the ways a matched player ended up
                  // stranded on the search screen.
                  if (!remoteCubit.isClosed) {
                    remoteCubit.setAnimGame(false);
                  }

                  await Future.delayed(AnimationService.animationDuration);

                  if (!mounted) return;

                  if (!remoteCubit.isClosed) {
                    remoteCubit.setFinalized(true);
                  }
                } catch (e, stack) {
                  debugPrint(
                    "⚠️ Exception launching remote game page: $e\n$stack",
                  );
                  // Nothing was opened: let a later state retry this match.
                  _pushedMatchKey = null;
                  if (!mounted) return;
                  remoteCubit.setAnimGame(false);
                  remoteCubit.setAnimated(false);
                  remoteCubit.setInternetError(true);
                }
              }
            },
            // Deliberately not restricted to the `success` transition: a state
            // change that arrives while the push is still being set up (or one
            // that follows a launch this page could not act on) must be able to
            // open the table too. `_gamePagePushed` is what keeps it to one.
            listenWhen: (oldState, newState) {
              return newState.status == RemoteGameStatus.success;
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            return GamicoPopScope(
              onWillPop: () async {
                final remoteCubit = context.read<RemoteCubit>();

                final enabled = remoteCubit.state.enabled;
                final forcePop = remoteCubit.state.forcePop;
                final animGame = remoteCubit.state.animGame;
                final finalized = remoteCubit.state.finalized;

                if (forcePop) return true;

                // Enable back when page is enabled
                if (enabled) {
                  final remoteCubit = context.read<RemoteCubit>();

                  remoteCubit.setAnimInit(false);
                  remoteCubit.setAnimated(true);

                  // Wait for transition to be performed
                  await Future.delayed(AnimationService.animationDuration);

                  // Stop animation
                  remoteCubit.setAnimated(false);

                  // Enable back
                  return true;
                }

                // If transition to game started but game failed to finalize/mount,
                // allow user to escape back safely when pressing back button.
                if (animGame && !finalized) {
                  remoteCubit.setAnimGame(false);
                  remoteCubit.setAnimated(false);
                  try {
                    remoteCubit.abortGame();
                  } catch (_) {}
                  return true;
                }

                // Disable back when page is disabled
                return false;
              },
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}
