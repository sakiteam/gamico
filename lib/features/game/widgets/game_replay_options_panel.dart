import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/card.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/game/utilities/replay_option.dart';
import 'package:gamico/features/game/widgets/game_replay_vote_juice.dart';
import 'package:gamico/languages/languages.dart';

/// The choices offered for the rematch, each showing how many players picked
/// it. Tapping the one already picked takes the vote back.
class GamicoReplayOptionsPanel extends StatelessWidget {
  final List<GamicoReplayOption> options;

  /// Solid background instead of the translucent default, for when the panel
  /// floats over the score table rather than sitting inside the popup.
  final bool opaque;

  const GamicoReplayOptionsPanel({
    super.key,
    required this.options,
    this.opaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final remoteGameCubit = context.watch<GamicoRemoteGameCubit>();
    final myVote = remoteGameCubit.myReplayVote;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: opaque
            ? const Color(0xFF15171C)
            : Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        boxShadow: opaque
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.replayVoteChooseOption,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          GamicoCard(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            borderWidth: 0.25,
            clipBehavior: Clip.antiAlias,
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final option in options)
                  Expanded(
                    child: _OptionCard(
                      option: option,
                      isSelected: myVote == option.id,
                      votesCount: remoteGameCubit.state.votesForReplayOption(
                        option.id,
                      ),
                      onTap: () => remoteGameCubit.voteReplay(option.id),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final GamicoReplayOption option;
  final bool isSelected;
  final int votesCount;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.votesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ColorService.accentColor;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AnimationService.animationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.125)
              : Colors.white.withValues(alpha: votesCount > 0 ? 0.08 : 0.04),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(option.icon, color: isSelected ? accent : Colors.white70),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: isSelected ? 1 : 0.9),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                // Around the dash too: the first vote must pop as well.
                child: GamicoVoteCountPop(
                  count: votesCount,
                  child: votesCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "$votesCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          "-",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 10.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
