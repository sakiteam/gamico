import 'package:flutter/widgets.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/features/game/utilities/roll_call.dart';

/// Everything a custom [GamicoRollCallPanelBuilder] needs to draw the
/// pre-deal wait/vote screen, with the state reading and profile lookups
/// already done — a builder only has to lay it out.
class GamicoRollCallPanelData {
  final GamicoRollCallStatus status;
  final GamicoUserModel? Function(String uid) profileOf;
  final String myUid;
  final bool iVoted;
  final bool iAmReady;

  /// Leaves the table — the game's own back flow, free before the deal.
  final VoidCallback onLeave;

  /// Flips this player's eject vote. Only meaningful once
  /// [GamicoRollCallStatus.voteOpen] and [iAmReady].
  final VoidCallback onToggleVote;

  const GamicoRollCallPanelData({
    required this.status,
    required this.profileOf,
    required this.myUid,
    required this.iVoted,
    required this.iAmReady,
    required this.onLeave,
    required this.onToggleVote,
  });
}

/// Draws `GamicoRollCallPanel` from [GamicoRollCallPanelData]. Set
/// `PlaySettings.rollCallPanelBuilder` to replace its default look — a host
/// app restyling it to match its own game, say — without touching how the
/// wait is tracked or voted on.
///
/// Expands to fill whatever space it is given, with or without a [Stack]
/// ancestor, so a game may embed it inline in its own layout (after its own
/// loader, say) instead of leaving it to the generic overlay
/// `GamicoRemoteGamePage` draws above the whole game by default.
typedef GamicoRollCallPanelBuilder =
    Widget Function(BuildContext context, GamicoRollCallPanelData data);
