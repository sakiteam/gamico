import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';

class GameUtility {
  // adventure
  final int? level;
  final AdventureUtility? adventureUtility;

  // remote
  final String? gameId;
  final bool? fakeOpponent;
  final bool? creatorOfCurrentGame;

  // tutorial
  final int? tutorialLessonIndex;

  // global
  final void Function()? onBackButtonPressed;
  final GameType gameType;

  GameUtility({
    required this.gameType,
    required this.onBackButtonPressed,
    this.level,
    this.gameId,
    this.fakeOpponent,
    this.creatorOfCurrentGame,
    this.tutorialLessonIndex,
    this.adventureUtility,
  });
}
