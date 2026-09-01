import 'package:flutter/material.dart';

/// A widget which adds a heartbeat effect to its contents.
/// 
/// This is a safe replacement for the `im_animations` HeartBeat widget which 
/// had a bug causing `TickerCanceled` unhandled exceptions upon disposal.
class HeartBeat extends StatefulWidget {
  /// The item to apply the heartbeat effect to.
  final Widget? child;

  /// The number of beats per minutes. Defaults to 70.
  final int beatsPerMinute;

  const HeartBeat({
    super.key,
    this.child,
    this.beatsPerMinute = 70,
  }) : assert(beatsPerMinute > 0, 'beatsPerMinute must be greater than 0.');

  @override
  State<HeartBeat> createState() => _HeartBeatState();
}

class _HeartBeatState extends State<HeartBeat> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _beatForward, _beatBackward;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 60000 ~/ widget.beatsPerMinute > 0
            ? 60000 ~/ widget.beatsPerMinute
            : 857,
      ),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    // Equivalent to zooming in the child at the specified interval.
    _beatForward = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.65, curve: Curves.easeIn),
      ),
    );

    // Equivalent to zooming out the child at the specified interval.
    _beatBackward = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.00, curve: Curves.easeIn),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    try {
      await _controller.repeat().orCancel;
    } on TickerCanceled {
      // The animation got canceled, probably because we were disposed.
      // We catch this to prevent unhandled exceptions.
    }
  }

  @override
  void didUpdateWidget(HeartBeat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.beatsPerMinute != widget.beatsPerMinute) {
      _controller.duration = Duration(
        milliseconds: 60000 ~/ widget.beatsPerMinute > 0
            ? 60000 ~/ widget.beatsPerMinute
            : 857,
      );
      _controller.reset();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // First scale up, then scale down.
    return Transform.scale(
      scale: _beatForward.value,
      child: Transform.scale(
        scale: _beatBackward.value,
        child: widget.child,
      ),
    );
  }
}
