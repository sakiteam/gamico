import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/game_exit_button.dart';
import 'package:gamico/commons/generics/game_replay_button.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/generics/loader.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/modes/game_mode_settings.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';
import 'package:gamico/languages/languages.dart';

class RemoteModeSettings implements GameModeSettings {
  @override
  void manageReplay(BuildContext context) {
    context.read<GamicoRemoteGameCubit>().replay();
  }

  @override
  String? localPlayerDescription(BuildContext context) {
    return null;
  }

  @override
  GamicoUserModel localPlayerProfile(BuildContext context) {
    return UserService.getUser() ?? const GamicoUserModel();
  }

  @override
  String? otherPlayerDescription(BuildContext context) {
    return null;
  }

  @override
  GamicoUserModel otherPlayerProfile(BuildContext context) {
    return context.select(
            (GamicoRemoteGameCubit gameCubit) => gameCubit.state.opponent) ??
        const GamicoUserModel();
  }

  @override
  String? gamePopupDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final gameEndStatus = context.select(
        (GamicoRemoteGameCubit remoteGameCubit) =>
            remoteGameCubit.state.gameEndStatus);
    final opponent = context.select((GamicoRemoteGameCubit remoteGameCubit) =>
        remoteGameCubit.state.opponent);
    final victory =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.victory);

    final possibleToPlayAgain = isPossibleToPlayAgain(context);

    switch (gameEndStatus) {
      case "INTERNAL_INVITATION":
        return l.internalInvitationDescription;
      case "EXTERNAL_INVITATION":
        return possibleToPlayAgain
            ? l.externalInvitationReplayPossibleDescription
            : l.externalInvitationReplayImpossibleDescription;
      case "INVITATION_ACCEPTATION":
        return l.invitationAcceptationDescription;
      case "INVITATION_REJECTION":
        return l.invitationRejectionDescription;
      case "INVITATION_WITHDRAWAL":
        return l.invitationWithdrawalDescription;
      case "REPLAY_IMPOSSIBLE":
        return l.replayImpossibleDescription;
      case "INTERNAL_NEEDINESS":
        return l.internalNeedinessDescription;
      case "EXTERNAL_NEEDINESS":
        return l.externalNeedinessDescription;
    }

    if (!possibleToPlayAgain) {
      return l.remotePossibleToPlayAgainDescription;
    }

    if (!isOpponentAvailable(context)) {
      if (opponent != null && opponent!.broke == true) {
        return l.externalNeedinessDescription;
      }

      return l.remoteOpponentUnavailableDescription;
    }

    if (victory == null) {
      return l.remoteDrawDescription;
    } else if (victory) {
      return l.remoteVictoryDescription;
    } else {
      return l.remoteDefeatDescription;
    }
  }

  @override
  String? gamePopupTitle(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final gameEndStatus = context.select(
        (GamicoRemoteGameCubit remoteGameCubit) =>
            remoteGameCubit.state.gameEndStatus);

    switch (gameEndStatus) {
      case "INTERNAL_INVITATION":
        return l.internalInvitationTitle;

      case "EXTERNAL_INVITATION":
        return l.externalInvitationTitle;

      case "INVITATION_ACCEPTATION":
        return l.invitationAcceptationTitle;

      case "INVITATION_REJECTION":
        return l.invitationRejectionTitle;

      case "INVITATION_WITHDRAWAL":
        return l.invitationWithdrawalTitle;

      case "REPLAY_IMPOSSIBLE":
        return l.replayImpossibleTitle;

      case "INTERNAL_NEEDINESS":
        return l.internalNeedinessTitle;

      case "EXTERNAL_NEEDINESS":
        return l.externalNeedinessTitle;
    }

    return null;
  }

  @override
  bool isOpponentAvailable(BuildContext context) {
    final opponentExited = context.select(
        (GamicoRemoteGameCubit remoteGameCubit) =>
            remoteGameCubit.state.opponentExited);

    final opponent = context.select((GamicoRemoteGameCubit remoteGameCubit) =>
        remoteGameCubit.state.opponent);

    final fakeOpponent = context.select(
        (GamicoRemoteGameCubit remoteGameCubit) =>
            remoteGameCubit.state.fakeOpponent);

    return !(opponentExited ||
        opponent == null ||
        fakeOpponent ||
        opponent!.online == false ||
        opponent!.broke == true);
  }

  @override
  bool isPossibleToPlayAgain(BuildContext context) {
    final coins = context.select(
        (GamicoUserCubit userCubit) => userCubit.state.user?.coins ?? 0);

    return coins >= Gamico.instance.gameSettings.playMinimumCowries;
  }

  @override
  bool isPossibleToPlayNextLevel(BuildContext context) {
    return false;
  }

  @override
  List<Widget> gamePopupButtons(
    BuildContext context,
    GamicoGameExitButton exitButton,
    GamicoGameReplayButton replayButton,
  ) {
    final l = GamicoLanguages.of(context);

    final gameEndStatus = context.select(
        (GamicoRemoteGameCubit remoteGameCubit) =>
            remoteGameCubit.state.gameEndStatus);

    final possibleToPlayAgain = isPossibleToPlayAgain(context);

    switch (gameEndStatus) {
      case "INTERNAL_INVITATION":
        final invitationCancellingButton = GamicoIconTextButton(
          onPressed: () {
            context.read<GamicoRemoteGameCubit>().withdraw();
          },
          text: l.globalCancel,
          iconData: Icons.close,
        );
        return [invitationCancellingButton];

      case "EXTERNAL_INVITATION":
        final rejectionButton = GamicoIconTextButton(
          onPressed: () {
            context.read<GamicoRemoteGameCubit>().rejectInvitation();
          },
          iconData: Icons.close,
          text: l.globalReject,
        );
        final acceptationButton = GamicoIconTextButton(
          color: Colors.orange,
          onPressed: !possibleToPlayAgain
              ? null
              : () {
                  context.read<GamicoRemoteGameCubit>().acceptInvitation();
                },
          iconData: Icons.check,
          text: l.globalAccept,
        );

        return [
          rejectionButton,
          acceptationButton,
        ];

      case "INVITATION_ACCEPTATION":
        return const [Center(child: GamicoLoader())];

      case "REPLAY_IMPOSSIBLE":
        final impossibleReplayButton = GamicoIconTextButton(
          onPressed: () {
            context.read<GamicoRemoteGameCubit>().resetGameEndStatus();
          },
          text: l.globalOK,
          iconData: Icons.check,
        );
        return [impossibleReplayButton];

      case "INTERNAL_NEEDINESS":
        final internalNeedinessButton = GamicoIconTextButton(
          onPressed: () {
            context.read<GamicoRemoteGameCubit>().resetGameEndStatus();
          },
          text: l.globalOK,
          iconData: Icons.check,
        );
        return [internalNeedinessButton];

      case "EXTERNAL_NEEDINESS":
        final externalNeedinessButton = GamicoIconTextButton(
          onPressed: () {
            context.read<GamicoRemoteGameCubit>().resetGameEndStatus();
          },
          text: l.globalOK,
          iconData: Icons.check,
        );
        return [externalNeedinessButton];

      default:
        final newGameButton = GamicoIconTextButton(
          onPressed: !possibleToPlayAgain
              ? null
              : () async {
                  final remoteGameCubit = context.read<GamicoRemoteGameCubit>();

                  NavigationService.pop(context);

                  remoteGameCubit.setNewRemoteGameActive(true);
                },
          text: l.gamePopupNewGame,
          iconData: Icons.sports_esports,
        );

        return [
          exitButton,
          newGameButton,
          replayButton,
        ];
    }
  }

  @override
  bool hasTripleAdAfterVictory(BuildContext context) {
    return true;
  }

  @override
  Key? gamePopupContentKey(BuildContext context) {
    return Key(context.select(
        (GamicoRemoteGameCubit gameCubit) => gameCubit.state.gameEndStatus));
  }

  @override
  bool displayStarsAfterVictory(BuildContext context) {
    return context
        .select(
            (GamicoRemoteGameCubit gameCubit) => gameCubit.state.gameEndStatus)
        .isEmpty;
  }

  @override
  String gamePageClosingPopupDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return l.remoteComplexCloseDescription(
        Gamico.instance.gameSettings.playMinimumCowries);
  }

  @override
  void gamePageManageCoinsAndStars(BuildContext context) {
    final gameCubit = context.read<GamicoGameCubit>();
    final userCubit = context.read<GamicoUserCubit>();

    final gameState = gameCubit.state;

    if (gameState.victory == true) {
      userCubit.incrementCowries(
          Gamico.instance.gameSettings.playMinimumCowries * gameState.stars);
      userCubit.incrementVictories();
    } else {
      userCubit
          .decrementCowries(Gamico.instance.gameSettings.playMinimumCowries);
      userCubit.incrementDefeats();
    }
  }

  @override
  bool shouldShowAds(BuildContext context) {
    return true;
  }

  @override
  void onExitingGame(BuildContext context) {
    final remoteCubit = context.read<RemoteCubit>();
    final remoteGameCubit = context.read<GamicoRemoteGameCubit>();

    if (remoteGameCubit.state.newRemoteGameActive) {
      remoteCubit.reset();
    } else if (remoteGameCubit.state.remoteGameInternetError) {
      remoteCubit.setInternetError(true);
    }
  }

  @override
  bool shouldForceExit(BuildContext context) {
    return (context
        .read<GamicoRemoteGameCubit>()
        .state
        .remoteGameInternetError);
  }

  @override
  void gamePageManageGamePopup(BuildContext context) {
    context.read<GamicoGameCubit>().setDisplayGamePopup(true);
  }
}
