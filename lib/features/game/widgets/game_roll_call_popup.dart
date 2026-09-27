import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/utilities/roll_call.dart';
import 'package:gamico/languages/languages.dart';

/// The popup that tells a player how a pre-deal wait ended for them: the
/// others never showed up (the match is cancelled), or the table went ahead
/// without them — and why. Shown by `GamicoRemoteGamePage` for games that
/// leave it to gamico, and callable by a game that runs its own exit.
abstract final class GamicoRollCallPopup {
  static ({String title, String description, IconData icon}) texts(
    GamicoLanguages l,
    GamicoRollCallOutcome outcome,
  ) {
    if (outcome.seatLost) {
      return (
        title: l.rollCallSeatLostTitle,
        description: l.rollCallSeatLostDescription,
        icon: Icons.sync_problem,
      );
    }
    final reason = outcome.exclusionReason;
    if (reason == null && outcome.othersLeft) {
      return outcome.otherPlayers <= 1
          ? (
              title: l.rollCallPlayerUnavailableTitle,
              description: l.rollCallPlayerLeftDescription,
              icon: Icons.person_off,
            )
          : (
              title: l.rollCallPlayersUnavailableTitle,
              description: l.rollCallPlayersLeftDescription,
              icon: Icons.group_off,
            );
    }
    if (reason == null) {
      return outcome.otherPlayers <= 1
          ? (
              title: l.rollCallPlayerUnavailableTitle,
              description: l.rollCallPlayerUnavailableDescription(
                GamicoRollCallRules.duelGrace.inSeconds,
              ),
              icon: Icons.person_off,
            )
          : (
              title: l.rollCallPlayersUnavailableTitle,
              description: l.rollCallPlayersUnavailableDescription,
              icon: Icons.group_off,
            );
    }
    switch (reason) {
      case GamicoRollCallReason.duelTimeout:
        return (
          title: l.rollCallCancelledTitle,
          description: l.rollCallExcludedDuel(
            GamicoRollCallRules.duelGrace.inSeconds,
          ),
          icon: Icons.timer_off,
        );
      case GamicoRollCallReason.vote:
        return (
          title: l.rollCallExcludedTitle,
          description: l.rollCallExcludedVote,
          icon: Icons.how_to_vote,
        );
      case GamicoRollCallReason.cap:
        return (
          title: l.rollCallExcludedTitle,
          description: l.rollCallExcludedCap(GamicoRollCallRules.cap.inSeconds),
          icon: Icons.timer_off,
        );
      case GamicoRollCallReason.allReady:
      case GamicoRollCallReason.grace:
        return (
          title: l.rollCallExcludedTitle,
          description: l.rollCallExcludedGrace,
          icon: Icons.timer_off,
        );
    }
  }

  /// Shows the popup on the app's root navigator, once the table's page has
  /// had time to leave.
  static void showLater(
    GamicoRollCallOutcome outcome, {
    Duration delay = const Duration(milliseconds: 350),
  }) {
    Future.delayed(delay, () {
      final context = NavigationService.globalNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      final l = GamicoLanguages.of(context);
      final content = texts(l, outcome);
      NavigationService.showPopup(
        context: context,
        builder: (_) => GamicoPopup(
          child: GamicoDialogPoster(
            icon: content.icon,
            iconColor: Colors.orange,
            title: content.title,
            description: content.description,
            simple: true,
            acceptationText: l.rollCallClose,
            acceptationIcon: Icons.check,
          ),
        ),
      );
    });
  }
}
