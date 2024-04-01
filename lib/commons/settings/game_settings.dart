import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/utilities/couple/couple_utility.dart';

class GameSettings {
  final int playMinimumCowries;

  final String developerAndroidId;
  final String developerAppleId;

  final int seedModulo;

  final List<GamicoCoupleUtility<String>> Function(
      BuildContext context, dynamic user) profileData;
  final Widget explanationPopup;

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

  const GameSettings({
    this.playMinimumCowries = 3,
    //
    required this.developerAndroidId,
    required this.developerAppleId,
    //
    this.seedModulo = 10,
    //
    required this.profileData,
    //
    required this.explanationPopup,
  });
}
