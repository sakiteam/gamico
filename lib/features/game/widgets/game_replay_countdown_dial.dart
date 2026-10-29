import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/features/game/widgets/game_replay_vote_juice.dart';
import 'package:gamico/languages/languages.dart';

/// Clock counting down to the moment the rematch starts without the players
/// who have not answered. Shown as soon as two of them agree while somebody is
/// still undecided, so nobody is surprised by the table leaving without them.
class GamicoReplayCountdownDial extends StatefulWidget {
  final DateTime? startedAt;
  final Duration duration;

  const GamicoReplayCountdownDial({
    super.key,
    required this.startedAt,
    required this.duration,
  });

  @override
  State<GamicoReplayCountdownDial> createState() =>
      _GamicoReplayCountdownDialState();
}

class _GamicoReplayCountdownDialState extends State<GamicoReplayCountdownDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  /// The last seconds' ticks.
  final GamicoCountdownBeat _beat = GamicoCountdownBeat();

  @override
  void initState() {
    super.initState();
    _ticker.addListener(() => _beat.update(context, _remainingSeconds));
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Duration get _elapsed =>
      DateTime.now().difference(widget.startedAt ?? DateTime.now());

  int get _remainingSeconds {
    final remainingMs =
        widget.duration.inMilliseconds - _elapsed.inMilliseconds;
    return (remainingMs / 1000).ceil().clamp(0, widget.duration.inSeconds);
  }

  double get _progress =>
      (_elapsed.inMilliseconds / widget.duration.inMilliseconds).clamp(
        0.0,
        1.0,
      );

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final remaining = _remainingSeconds;
        // Red, with the digit beating, over the last seconds.
        final accent = GamicoReplayVoteJuice.countdownColor(
          ColorService.accentColor,
          remaining,
        );
        final pulse = GamicoReplayVoteJuice.countdownPulse(
          widget.duration.inMilliseconds - _elapsed.inMilliseconds,
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accent.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: const Size(50, 50),
                painter: _ClockDialPainter(
                  progress: _progress,
                  accentColor: accent,
                ),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: Transform.scale(
                      scale: pulse,
                      child: Text(
                        "${remaining}s",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.replayVoteCountdown(remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.replayVoteStartingSoon,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A clock face with its twelve ticks and a clockwise sweep starting at noon.
class _ClockDialPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  const _ClockDialPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 3.0;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, trackPaint);

    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 12);
      final isCardinal = i % 3 == 0;
      final tickLength = isCardinal ? 4.5 : 2.5;

      tickPaint
        ..color = Colors.white.withValues(alpha: isCardinal ? 0.75 : 0.35)
        ..strokeWidth = isCardinal ? 2.0 : 1.2;

      canvas.drawLine(
        Offset(
          center.dx + (radius - 5.0 - tickLength) * math.cos(angle),
          center.dy + (radius - 5.0 - tickLength) * math.sin(angle),
        ),
        Offset(
          center.dx + (radius - 5.0) * math.cos(angle),
          center.dy + (radius - 5.0) * math.sin(angle),
        ),
        tickPaint,
      );
    }

    if (progress <= 0.0) return;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.8,
    );

    final tipAngle = startAngle + sweepAngle;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );

    canvas.drawCircle(
      tip,
      4.5,
      Paint()
        ..color = accentColor.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );
    canvas.drawCircle(tip, 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ClockDialPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor;
}
