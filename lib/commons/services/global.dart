import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/authentication_popup.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';

class GamicoGlobalService {
  static String simplifyProductName(String name) {
    String finalName = name.replaceAll("(${Gamico.instance.title})", "");

    for (final title in Gamico.instance.titles) {
      finalName = finalName.replaceAll("($title)", "");
    }

    return finalName.trim();
  }

  // Random

  static final random = Random();

  static String getRandomPlayerName() {
    final code = GamicoGlobalService.random.nextInt(900) + 100;

    final names = [
      "DecayedMoonburner",
      "PollutedFlamespear",
      "DesolateFlamehorde",
      "RampantReptile",
      "VampiricIncinerator",
      "VileDog",
      "OrbitalLizard",
      "PugnaciousRattlesnake",
      "ElectrifiedViper",
      "TenaciousThrone",
      "SolidMachinegun",
      "InsidiousGPU",
      "BurningPlasma",
      "IndestructableCrater",
      "ViralObscure",
      "BloodyContract",
      "DecayedKrampus",
      "RagingJailbreak",
      "ElectrifiedCookie",
      "BreakneckMicrochip",
    ];

    names.shuffle();

    return "${names.first}$code";
  }

  // Execution

  static void executeIfConnected(
    BuildContext context,
    void Function() function,
  ) {
    bool connected = context.read<InternetCubit>().state.connected;

    if (connected) {
      function();
    } else {
      final l = GamicoLanguages.of(context);

      NavigationService.showPopup(
        context: context,
        builder: (_) {
          return GamicoPopup(
            child: GamicoDialogPoster(
              icon: Icons.wifi_off,
              title: l.homeMultiplayerButtonConnectionErrorTitle,
              description: l.homeMultiplayerButtonConnectionErrorDescription,
              simple: true,
              acceptationText: l.globalClose,
              acceptationIcon: Icons.close,
            ),
          );
        },
      );
    }
  }

  static void executeIfAuthenticated(
    BuildContext context,
    void Function() function,
  ) {
    bool authenticated = context
        .read<AuthenticationCubit>()
        .state
        .authenticated;

    if (authenticated) {
      function();
    } else {
      NavigationService.showPopup(
        context: context,
        dismissible: false,
        draggable: false,
        builder: (_) {
          return GamicoAuthenticationPopup(
            onSuccess: () {
              if (context.mounted) {
                function();
              }
            },
          );
        },
      );
    }
  }

  static void executeIfNotBroke(
    BuildContext context,
    GameType gameType,
    void Function() function,
  ) {
    final broke = context.read<GamicoUserCubit>().state.user?.broke ?? true;

    if (!broke) {
      function();
    } else {
      NavigationService.showCowriesPopup(
        context,
        Gamico.instance.gameSettings.playMinimumCoins,
      );
    }
  }

  // Completer

  static Future waitWhile(
    bool Function() test, [
    Duration interval = const Duration(milliseconds: 250),
  ]) {
    final completer = Completer();

    check() {
      if (!test()) {
        completer.complete();
      } else {
        Timer(interval, check);
      }
    }

    check();

    return completer.future;
  }
}
