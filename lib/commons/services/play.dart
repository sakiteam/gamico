import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlayService {
  static String authCode = "";

  static bool gameServicesEnabled = false;

  static void initGameServices([int exponent = 0]) async {
    try {
      if (await enableGameServices()) {
        final player = AuthenticationCubit.player;

        if (player != null) {
          UserService.displayName = player.displayName;
        }
      } else {
        await Future.delayed(pow(2, exponent).seconds);

        initGameServices(exponent + 1);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<bool> enableGameServices() async {
    try {
      await GameAuth.signIn();

      if (UserService.authenticated) {
        gameServicesEnabled = true;
        return true;
      }

      if (Platform.isAndroid) {
        final serverAuthCode = await GameAuth.getAuthCode(authCode);

        if (serverAuthCode != null) {
          final playGamesCredential = PlayGamesAuthProvider.credential(
            serverAuthCode: serverAuthCode,
          );

          await FirebaseAuth.instance.signInWithCredential(playGamesCredential);

          gameServicesEnabled = true;
        } else {
          gameServicesEnabled = false;
        }
      } else {
        final credential = GameCenterAuthProvider.credential();
        await FirebaseAuth.instance.signInWithCredential(credential);
        gameServicesEnabled = true;
      }
    } catch (e) {
      gameServicesEnabled = false;
    }

    return gameServicesEnabled;
  }
}
