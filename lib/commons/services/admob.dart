import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages Google Mobile Ads initialization and lifecycle.
class AdmobService {
  const AdmobService._();

  static Future<InitializationStatus>? _initFuture;

  /// Completes when `MobileAds.instance.initialize()` finishes.
  /// Await this before calling any SDK method that requires initialisation.
  static Future<InitializationStatus>? get initFuture => _initFuture;

  /// Initializes the Google Mobile Ads SDK asynchronously without blocking startup.
  static Future<InitializationStatus> initialize() {
    _initFuture ??= MobileAds.instance.initialize();
    return _initFuture!;
  }
}
