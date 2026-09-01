import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/settings/matchmaking_settings.dart';

@immutable
class RemoteUtility {
  final MatchmakingSettings matchmakingSettings;
  final bool adventure;
  final int seedModulo;

  final String developerAndroidId;
  final String developerAppleId;

  final Widget Function(
    BuildContext context,
    int index,
    int stars,
    bool locked,
    void Function()? replay,
    void Function()? newGame,
  )? levelsBuilder;

  bool get isDeveloper {
    return [developerAppleId, developerAndroidId].contains(UserService.uid);
  }

  String get developerId {
    if (isDeveloper) {
      return UserService.uid == developerAndroidId
          ? developerAppleId
          : developerAndroidId;
    }

    return Platform.isAndroid ? developerAndroidId : developerAppleId;
  }

  const RemoteUtility({
    required this.adventure,
    required this.matchmakingSettings,
    required this.levelsBuilder,
    this.seedModulo = 10,
    required this.developerAppleId,
    required this.developerAndroidId,
  });

  /// Copy of this utility whose matchmaking settings are pinned to the single
  /// resolved [mode] a "no preference" search ended up playing in.
  RemoteUtility withMatchmakingMode(String? mode) {
    return RemoteUtility(
      adventure: adventure,
      matchmakingSettings: matchmakingSettings.withMode(mode),
      levelsBuilder: levelsBuilder,
      seedModulo: seedModulo,
      developerAppleId: developerAppleId,
      developerAndroidId: developerAndroidId,
    );
  }
}
