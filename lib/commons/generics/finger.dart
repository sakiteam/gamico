import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/services/gif.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum GamicoFingerType {
  click,
  clickAndClick,
  clickAndRelease,
}

class GamicoFinger extends StatefulWidget {
  final Offset beginOffset;
  final Offset endOffset;

  final Size containerSize;
  final Size fingerSize;

  final Duration clickDuration;
  final Duration moveDuration;
  final Duration fadeDuration;

  final GamicoFingerType type;

  const GamicoFinger({
    super.key,
    this.beginOffset = Offset.zero,
    this.endOffset = Offset.zero,
    required this.containerSize,
    required this.fingerSize,
    this.clickDuration = const Duration(milliseconds: 500),
    this.moveDuration = const Duration(milliseconds: 1000),
    this.fadeDuration = const Duration(milliseconds: 500),
    required this.type,
  });

  @override
  State<GamicoFinger> createState() => _GamicoFingerState();
}

class _GamicoFingerState extends State<GamicoFinger>
    with TickerProviderStateMixin {
  GifController? _gifController;
  AnimationController? _animationController;
  AnimationController? _fadeController;

  Duration get clickDuration => widget.clickDuration;
  Duration get moveDuration => widget.moveDuration;
  Duration get fadeDuration => widget.fadeDuration;

  @override
  void initState() {
    super.initState();

    _gifController = GifController(vsync: this);
    _animationController =
        AnimationController(vsync: this, duration: moveDuration);
    _fadeController = AnimationController(vsync: this, duration: fadeDuration);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _animate();
    });
  }

  @override
  void dispose() {
    _gifController?.dispose();
    _animationController?.dispose();
    _fadeController?.dispose();

    _gifController = null;
    _animationController = null;
    _fadeController = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fingerWidth = widget.fingerSize.width;
    final fingerHeight = widget.fingerSize.height;

    return IgnorePointer(
      child: Container(
        width: widget.containerSize.width,
        height: widget.containerSize.height,
        alignment: Alignment.center,
        child: SizedBox(
          width: fingerWidth,
          height: fingerHeight,
          child: Gif(
            autostart: Autostart.no,
            controller: _gifController,
            image: Image.asset("assets/images/finger.gif").image,
            width: fingerWidth,
            height: fingerHeight,
          ),
        ),
      )
          .animate(autoPlay: false, controller: _animationController)
          .move(begin: widget.beginOffset, end: widget.endOffset)
          .animate(autoPlay: false, controller: _fadeController)
          .fadeIn(),
    );
  }

  void _animate() async {
    while (mounted) {
      await _fadeController?.forward();

      switch (widget.type) {
        case GamicoFingerType.click:
          await _animateFinger(1, true);
          break;

        case GamicoFingerType.clickAndClick:
          await _animateFinger(1, true);
          await _animationController?.forward();
          await _animateFinger(1, true);
          _animationController?.reset();
          break;

        case GamicoFingerType.clickAndRelease:
          await _animateFinger(0.75, true);
          await _animationController?.forward();
          await _animateFinger(1, false);
          _animationController?.reset();

          break;
      }

      if (kDebugMode && Platform.isIOS) return;

      await _fadeController?.reverse();
    }
  }

  Future<void> _animateFinger(double percentage, bool reset) async {
    if (reset) _gifController?.reset();
    await _gifController?.animateTo(percentage, duration: clickDuration);
  }
}
