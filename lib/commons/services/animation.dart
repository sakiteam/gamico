import 'package:flutter/foundation.dart';

class AnimationService {
  static const Duration animationDuration =
      Duration(milliseconds: kDebugMode ? 500 : 250);
  static final Duration animationDurationHalf =
      Duration(milliseconds: animationDuration.inMilliseconds ~/ 2);
  static final Duration animationDurationQuarter =
      Duration(milliseconds: animationDuration.inMilliseconds ~/ 4);

  static const Duration duration =
      Duration(milliseconds: kDebugMode ? 500 : 250);
}
