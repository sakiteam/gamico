import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/gif.dart';

/// Preloads and caches image and animation assets declared in the app configuration.
class GamicoAssetPreloader {
  const GamicoAssetPreloader._();

  /// Precaches standard raster images and GIFs in the Flutter image cache.
  static void precache(BuildContext context) {
    for (final image in (Gamico.instance.cacheSettings?.images ?? <String>[])) {
      final imageProvider = AssetImage(image);

      // A failed preload is never fatal: the image simply loads on demand.
      // Without onError, the failure is reported as an unhandled FlutterError
      // (and recorded as a fatal crash on low-memory devices).
      precacheImage(imageProvider, context, onError: (_, _) {});

      if (image.endsWith("gif")) {
        GifService.precacheImage(imageProvider);
      }
    }
  }
}
