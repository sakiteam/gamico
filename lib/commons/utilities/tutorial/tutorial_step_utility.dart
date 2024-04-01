import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';

abstract class TutorialStepUtility<GameCubitType> {
  String get instruction;
  MessageUtility? get message;

  bool condition(GameCubitType gameCubit);
  Future<void> execute(GameCubitType gameCubit);
}
