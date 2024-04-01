import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';

class GamicoLocker extends StatefulWidget {
  final double size;
  final Widget Function(BuildContext context, void Function() animate) builder;
  final bool mute;

  const GamicoLocker({
    super.key,
    required this.size,
    required this.builder,
    this.mute = false,
  });

  @override
  State<GamicoLocker> createState() => _GamicoLockerState();
}

class _GamicoLockerState extends State<GamicoLocker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> animation;

  void animate() {
    if (_animationController.isCompleted) {
      _animationController.reset();
    }

    _animationController.forward();

    if (!widget.mute) {
      context.read<GamicoMusicCubit>().playLockBruitage();
    }
  }

  @override
  void initState() {
    super.initState();

    final contentWidth = widget.size;
    final o = 12 / contentWidth;
    final o2 = 8 / contentWidth;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0), end: Offset(o, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(o, 0), end: Offset(-o, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(-o, 0), end: Offset(o - o2, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(o - o2, 0), end: Offset(-(o - o2), 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(-(o - o2), 0), end: const Offset(0, 0)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: widget.builder(context, animate),
    );
  }
}
