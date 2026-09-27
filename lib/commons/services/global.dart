import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/generics/authentication_popup.dart';
import 'package:gamico/commons/generics/coins_popup.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/languages/languages.dart';

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

  // Execution guards

  /// The context a guard should actually work with.
  ///
  /// Each guard below starts by reading an app-level cubit off the caller's
  /// context, and several callers hold on to one for a while: a callback
  /// handed down into a dialog route outlives the element that built it, so
  /// by the time the button is tapped that element may already be gone.
  ///
  /// Reading a provider off a dead element does not fail cleanly. The lookup
  /// finds nothing (a defunct element has no ancestors), provider then builds
  /// its "not found" exception, and composing the message reads
  /// `context.widget` — which throws, because `_widget` is null on an
  /// unmounted element. What lands in Crashlytics is therefore provider's own
  /// error path, which reads like a missing provider but is not one.
  ///
  /// `context.mounted` is precisely `_widget != null`, so it is safe to ask
  /// even of a dead element. When it says no, fall back to the root
  /// navigator's context: [GamicoProviders] wraps the [MaterialApp], so that
  /// context reaches the very same cubits, and it stays alive as long as the
  /// app does. The guard then runs normally and shows its popup on the root
  /// navigator instead of crashing.
  static BuildContext? _liveContext(BuildContext context) => context.mounted
      ? context
      : NavigationService.globalNavigatorKey.currentContext;

  static void executeIfConnected(
    BuildContext context,
    void Function() function,
  ) {
    final ctx = _liveContext(context);
    if (ctx == null) return;

    bool connected = ctx.read<InternetCubit>().state.connected;

    if (connected) {
      function();
    } else {
      final l = GamicoLanguages.of(ctx);

      NavigationService.showPopup(
        context: ctx,
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
    final ctx = _liveContext(context);
    if (ctx == null) return;

    bool authenticated = ctx.read<AuthenticationCubit>().state.authenticated;

    if (authenticated) {
      function();
    } else {
      NavigationService.showPopup(
        context: ctx,
        dismissible: false,
        draggable: false,
        builder: (_) {
          return GamicoAuthenticationPopup(
            onSuccess: () {
              if (ctx.mounted) {
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
    final ctx = _liveContext(context);
    if (ctx == null) return;

    final broke = ctx.read<GamicoUserCubit>().state.user?.broke ?? true;

    if (!broke) {
      function();
    } else {
      CoinsPopup.showCowriesPopup(
        ctx,
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
