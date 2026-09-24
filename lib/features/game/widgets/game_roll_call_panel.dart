import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/languages/languages.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// The pre-deal wait of an online table, drawn over the game's own loader:
/// who is there (a check) and who is still connecting (a spinner), and when
/// the wait ends. Three seats or more: when the table starts anyway and — once
/// the vote is open — the one button that flips this player's vote between
/// ejecting the absent and waiting for them. A duel: when it is cancelled,
/// shown only once the other player is late.
///
/// It covers the game's own back button, so it carries its own way out.
class GamicoRollCallPanel extends StatelessWidget {
  /// Leaves the table — the game's own back flow, free before the deal.
  final VoidCallback onLeave;

  const GamicoRollCallPanel({super.key, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (GamicoRemoteGameCubit cubit) => cubit.state.rollCall,
    );
    if (status == null) return const SizedBox.shrink();

    final l = GamicoLanguages.of(context);
    final myUid = LocalStorageService.uid;
    final opponents = context.select(
      (GamicoRemoteGameCubit cubit) => cubit.state.opponents,
    );
    final me = context.select(
      (GamicoGameCubit cubit) => cubit.userCubit.state.user,
    );

    GamicoUserModel? profileOf(String uid) {
      if (uid == myUid && me is GamicoUserModel) return me;
      for (final opponent in opponents) {
        if (opponent is GamicoUserModel && opponent.id == uid) return opponent;
      }
      return null;
    }

    final iVoted = status.ejectVotes.contains(myUid);
    final iAmReady = status.readyIds.contains(myUid);

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                // A Material of its own: the tiles below need one, and the
                // game page may scale this whole layer (see InkFittedBox).
                child: Material(
                  color: Colors.white,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status.duel
                              ? l.rollCallWaitingOpponentTitle
                              : l.rollCallWaitingTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorService.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.duel
                              ? l.rollCallCancelsIn(status.secondsUntilCancel)
                              : l.rollCallStartsIn(status.secondsUntilStart),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorService.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              for (final uid in status.playerIds)
                                _RollCallTile(
                                  profile: profileOf(uid),
                                  isMe: uid == myUid,
                                  ready: status.readyIds.contains(uid),
                                  away: status.awayIds.contains(uid),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (status.voteOpen) ...[
                          Text(
                            l.rollCallEjectVotes(
                              status.ejectVoteCount,
                              status.ejectVotesNeeded,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GamicoIconTextButton(
                            iconData: iVoted
                                ? Icons.hourglass_top
                                : Icons.person_remove,
                            text: iVoted ? l.rollCallWait : l.rollCallEject,
                            color: iVoted ? null : ColorService.accentColor,
                            onPressed: iAmReady
                                ? () => context
                                      .read<GamicoRemoteGameCubit>()
                                      .toggleEjectVote()
                                : null,
                          ),
                        ] else if (!status.duel)
                          Text(
                            l.rollCallVoteOpensIn(status.secondsUntilVote),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 4),
                        TextButton.icon(
                          onPressed: onLeave,
                          icon: const Icon(Icons.logout, size: 18),
                          label: Text(l.rollCallLeave),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RollCallTile extends StatelessWidget {
  final GamicoUserModel? profile;
  final bool isMe;
  final bool ready;
  final bool away;

  const _RollCallTile({
    required this.profile,
    required this.isMe,
    required this.ready,
    required this.away,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final photo = profile?.photo;
    final name = isMe ? l.rollCallYou : (profile?.name ?? "…");

    const placeholder = Icon(Icons.person, color: Colors.white, size: 20);

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: ColorService.primaryColor,
        child: ClipOval(
          child: photo == null
              ? placeholder
              : CachedNetworkImage(
                  imageUrl: photo,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorListener: (_) {},
                  errorWidget: (_, _, _) => placeholder,
                ),
        ),
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.w500),
      ),
      subtitle: Text(
        ready
            ? (away ? l.rollCallAway : l.rollCallReady)
            : l.rollCallConnecting,
        style: TextStyle(
          color: ready && !away ? Colors.green.shade700 : Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: ready
              ? Icon(Icons.check_circle, color: Colors.green.shade600)
              : LoadingAnimationWidget.threeArchedCircle(
                  color: ColorService.accentColor,
                  size: 22,
                ),
        ),
      ),
    );
  }
}
