import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Centralized utility for OS share sheets with robust iPad / iOS origin
/// handling and crash-proof execution in Gamico.
class GamicoShareUtility {
  /// Computes a safe [Rect] origin for iPad / iOS share sheets from a [BuildContext].
  /// If the widget's render box cannot be resolved or has no size, falls back
  /// to a rect centered on the screen.
  static Rect originFromContext(BuildContext? context) {
    if (context != null && context.mounted) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.width > 0 && box.size.height > 0) {
        return box.localToGlobal(Offset.zero) & box.size;
      }
      final size = MediaQuery.maybeSizeOf(context);
      if (size != null && size.width > 0 && size.height > 0) {
        return Rect.fromCenter(
          center: size.center(Offset.zero),
          width: 1,
          height: 1,
        );
      }
    }
    // Fallback if context is not available / unmounted
    return const Rect.fromLTWH(0, 0, 100, 100);
  }

  /// Safely invokes [SharePlus.instance.share] with guaranteed non-null
  /// [sharePositionOrigin] and error handling to prevent uncaught platform crashes.
  static Future<ShareResult?> share({
    BuildContext? context,
    String? text,
    String? subject,
    List<XFile>? files,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final origin = sharePositionOrigin ?? originFromContext(context);
      return await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          files: files,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("GamicoShareUtility.share error: $e\n$stackTrace");
      return null;
    }
  }
}
