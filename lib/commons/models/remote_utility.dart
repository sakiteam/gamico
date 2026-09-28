import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/settings/matchmaking_settings.dart';

@immutable
class RemoteUtility {
  final MatchmakingSettings matchmakingSettings;
  final bool adventure;
  final int seedModulo;

  final String developerAndroidId;
  final String developerAppleId;

  /// Whether each opponent's coin balance is watched live for the whole match.
  ///
  /// Leave it off unless the table actually shows that figure moving. A
  /// balance changes every time its owner is paid — at every settled hand in a
  /// scoring game — and each change rebuilds the opponent, re-sorts the roster
  /// and emits a new state that every listener of the remote cubit reacts to.
  /// A game that never displays it pays that N-1 times per payout for nothing.
  ///
  /// Off does not mean absent: `coins` is then read once with `name` and
  /// `photo`, so the opponent still carries the balance it had when the table
  /// was formed. Only live updates are lost.
  final bool watchOpponentCoins;

  /// Default for `RemoteGameUtility.embedsRollCallPanel` on games built from
  /// this utility: true when the game embeds `GamicoRollCallPanel` itself
  /// (after its own loader, in its own layout) instead of leaving the
  /// framework to draw its generic copy above the whole game.
  final bool embedsRollCallPanel;

  final Widget Function(
    BuildContext context,
    int index,
    int stars,
    bool locked,
    void Function()? replay,
    void Function()? newGame,
  )?
  levelsBuilder;

  bool get isDeveloper {
    return [
      developerAppleId,
      developerAndroidId,
    ].contains(LocalStorageService.uid);
  }

  String get developerId {
    if (isDeveloper) {
      return LocalStorageService.uid == developerAndroidId
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
    this.watchOpponentCoins = true,
    this.embedsRollCallPanel = false,
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
      watchOpponentCoins: watchOpponentCoins,
      embedsRollCallPanel: embedsRollCallPanel,
    );
  }
}
