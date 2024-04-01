import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_game_services/firebase_game_services.dart';

class PlayService {
  static bool gameServicesEnabled = false;

  static void initGameServices([int exponent = 0]) async {
    try {
      if (await enableGameServices()) {
        UserService.displayName =
            await FirebaseGameServices.instance.getPlayerName() ?? "";
      } else {
        await Future.delayed(pow(2, exponent).seconds);

        initGameServices(exponent + 1);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<bool> enableGameServices() async {
    gameServicesEnabled = await FirebaseGameServices.instance.signIn();
    return gameServicesEnabled;
  }
}
