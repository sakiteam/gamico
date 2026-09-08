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

      precacheImage(imageProvider, context);

      if (image.endsWith("gif")) {
        GifService.precacheImage(imageProvider);
      }
    }
  }
}
