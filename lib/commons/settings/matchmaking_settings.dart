import 'package:gamico/commons/models/gamico_user_model.dart';

class MatchmakingSettings<T extends GamicoUserModel> {
  final int minLevel;
  final int maxLevel;

  final int increment;

  final int Function(T? user) getMatchmakingLevel;

  final String? mode;

  const MatchmakingSettings({
    required this.minLevel,
    required this.maxLevel,
    required this.getMatchmakingLevel,
    required this.increment,
    this.mode,
  });
}
