import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/services/color.dart';

/// The motions and sounds of the rematch vote, shared by every end-of-match
/// popup that holds one — the framework's own [GamicoReplayVoteButton], and a
/// game drawing its own (Crazy Eights): another player's vote landing, the
/// whole table being in, a vote reaching an option, and the last seconds of
/// the countdown.
abstract final class GamicoReplayVoteJuice {
  /// Whether the vote may vibrate — the host app's own setting.
  static bool Function() vibrate = () => true;

  /// Played when someone else's vote lands.
  static String voteSound = "assets/bruitages/click.opus";

  /// Played when the whole table is in.
  static String allInSound = "assets/bruitages/click.opus";

  /// Played on each of the countdown's last seconds.
  static String tickSound = "assets/bruitages/click.opus";

  /// The countdown's last seconds that tick, and turn red.
  static const int criticalSeconds = 3;

  static void play(
    BuildContext context,
    String asset, {
    double gain = 1.0,
    double speed = 1.0,
  }) {
    try {
      context.read<GamicoMusicCubit>().playBruitage(
        asset,
        false,
        gain,
        speed,
        speed,
      );
    } catch (_) {}
  }

  static void haptic(Future<void> Function() feedback) {
    if (vibrate()) feedback();
  }

  /// The countdown's colour: [accent], red over its last seconds.
  static Color countdownColor(Color accent, int remaining) =>
      remaining > 0 && remaining <= criticalSeconds ? Colors.redAccent : accent;

  /// How much bigger the countdown's digit reads this frame: a beat at each
  /// of the last seconds, dying out over the second. [remainingMs] is what is
  /// left of the countdown.
  static double countdownPulse(int remainingMs) {
    if (remainingMs <= 0 || remainingMs > criticalSeconds * 1000) return 1.0;
    final double intoSecond = 1.0 - (remainingMs % 1000) / 1000.0;
    return 1.0 + 0.35 * math.pow(1.0 - intoSecond, 3);
  }
}

/// Ticks each of the countdown's last seconds, once — fed the seconds left
/// every frame by the dial that owns it.
class GamicoCountdownBeat {
  int? _last;

  void update(BuildContext context, int remaining) {
    if (remaining == _last) return;
    _last = remaining;
    if (remaining <= 0 || remaining > GamicoReplayVoteJuice.criticalSeconds) {
      return;
    }
    // Louder and lower as the end nears.
    final double urgency =
        (GamicoReplayVoteJuice.criticalSeconds - remaining) /
        math.max(1, GamicoReplayVoteJuice.criticalSeconds - 1);
    GamicoReplayVoteJuice.play(
      context,
      GamicoReplayVoteJuice.tickSound,
      gain: 0.6 + 0.3 * urgency,
      speed: 0.95 - 0.1 * urgency,
    );
    GamicoReplayVoteJuice.haptic(HapticFeedback.lightImpact);
  }
}

/// The "Rejouer" button, alive to the vote: when another player's vote lands
/// it hops, with a light click a little higher each time; when the whole
/// table is in it hops higher and glows, with a fuller sound, until that
/// changes. The local player's own vote moves nothing — the tap already
/// answered it.
class GamicoVoteBump extends StatefulWidget {
  /// Players in so far.
  final int count;

  /// Players who can vote. Below two there is no vote to be had.
  final int total;

  /// Whether the local player's vote is among [count].
  final bool mine;

  /// The glow's colour; the app's accent when null.
  final Color? color;

  final Widget child;

  const GamicoVoteBump({
    super.key,
    required this.count,
    required this.total,
    required this.mine,
    this.color,
    required this.child,
  });

  @override
  State<GamicoVoteBump> createState() => _GamicoVoteBumpState();
}

class _GamicoVoteBumpState extends State<GamicoVoteBump>
    with TickerProviderStateMixin {
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  /// Whether the last hop was the whole table coming in: it goes higher.
  bool _bigHop = false;

  static bool _allIn(GamicoVoteBump w) => w.total >= 2 && w.count >= w.total;

  @override
  void didUpdateWidget(covariant GamicoVoteBump old) {
    super.didUpdateWidget(old);
    final bool allIn = _allIn(widget);
    final bool wasAllIn = _allIn(old);
    if (allIn && !wasAllIn) {
      _bigHop = true;
      _hop.forward(from: 0);
      _glow.repeat(reverse: true);
      GamicoReplayVoteJuice.play(
        context,
        GamicoReplayVoteJuice.allInSound,
        gain: 0.75,
      );
      GamicoReplayVoteJuice.haptic(HapticFeedback.mediumImpact);
      return;
    }
    if (!allIn && wasAllIn) {
      _glow.stop();
      _glow.value = 0;
    }
    final bool mineJustNow = widget.mine && !old.mine;
    if (widget.count > old.count && !mineJustNow) {
      _bigHop = false;
      _hop.forward(from: 0);
      final double share = widget.total <= 0 ? 0 : widget.count / widget.total;
      GamicoReplayVoteJuice.play(
        context,
        GamicoReplayVoteJuice.voteSound,
        gain: 0.5,
        speed: 1.0 + 0.3 * share,
      );
      GamicoReplayVoteJuice.haptic(HapticFeedback.selectionClick);
    }
  }

  @override
  void dispose() {
    _hop.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? ColorService.accentColor;
    return AnimatedBuilder(
      animation: Listenable.merge([_hop, _glow]),
      builder: (context, child) {
        final double arc = math.sin(math.pi * _hop.value);
        final double lift = _bigHop ? 12.0 : 7.0;
        final double glow = _glow.isAnimating || _glow.value > 0
            ? 0.35 + 0.35 * _glow.value
            : 0.0;
        return Transform.translate(
          offset: Offset(0, -lift * arc),
          child: Transform.scale(
            scale: 1.0 + (_bigHop ? 0.12 : 0.07) * arc,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: glow <= 0
                    ? null
                    : [
                        BoxShadow(
                          color: color.withValues(alpha: glow),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// An option's vote count, popping each time a vote reaches it: it swells,
/// flashes and a ring spreads from it — so where the table leans reads at a
/// glance. Silent: the button carries the sound.
class GamicoVoteCountPop extends StatefulWidget {
  final int count;
  final Color? color;
  final Widget child;

  const GamicoVoteCountPop({
    super.key,
    required this.count,
    this.color,
    required this.child,
  });

  @override
  State<GamicoVoteCountPop> createState() => _GamicoVoteCountPopState();
}

class _GamicoVoteCountPopState extends State<GamicoVoteCountPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void didUpdateWidget(covariant GamicoVoteCountPop old) {
    super.didUpdateWidget(old);
    if (widget.count > old.count) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? ColorService.accentColor;
    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        final double t = _pop.value;
        final bool live = t > 0 && t < 1;
        final double swell = live
            ? math.sin(math.pi * math.min(1.0, t * 1.6))
            : 0.0;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // The ring, spreading and fading — outside the layout, so the
            // count keeps its place.
            if (live)
              Positioned.fill(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Container(
                    width: 14 + 34 * t,
                    height: 14 + 34 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.7 * (1 - t)),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            Transform.scale(
              scale: 1.0 + 0.35 * swell,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: swell <= 0
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.6 * swell),
                            blurRadius: 10,
                          ),
                        ],
                ),
                child: child,
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
