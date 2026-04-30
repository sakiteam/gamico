import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';

class GameUtility {
  final GameType type;
  final void Function()? onBackButtonPressed;

  const GameUtility({required this.type, required this.onBackButtonPressed});
}

class AdventureGameUtility extends GameUtility {
  final int level;
  final AdventureUtility adventureUtility;
  final RemoteUtility? remoteUtility;

  const AdventureGameUtility({
    required super.onBackButtonPressed,
    required this.level,
    required this.adventureUtility,
    required this.remoteUtility,
  }) : super(type: GameType.adventure);
}

class PassAndPlayGameUtility extends GameUtility {
  const PassAndPlayGameUtility({required super.onBackButtonPressed})
    : super(type: GameType.passAndPlay);
}

class RemoteGameUtility extends GameUtility {
  final int? level;
  final String gameId;
  final bool fakeOpponent;
  final bool creatorOfCurrentGame;
  final RemoteUtility remoteUtility;
  final AdventureUtility? adventureUtility;
  final bool friend;

  const RemoteGameUtility({
    required super.onBackButtonPressed,
    required this.level,
    required this.creatorOfCurrentGame,
    required this.fakeOpponent,
    required this.gameId,
    required this.remoteUtility,
    required this.adventureUtility,
    this.friend = false,
  }) : super(type: GameType.remote);
}

class TutorialGameUtility extends GameUtility {
  final int tutorialLessonIndex;

  const TutorialGameUtility({
    required super.onBackButtonPressed,
    required this.tutorialLessonIndex,
  }) : super(type: GameType.tutorial);
}
