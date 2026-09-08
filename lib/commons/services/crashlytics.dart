import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Handles global crash reporting, error filtering, and uncaught exception capture.
class GamicoCrashlyticsService {
  const GamicoCrashlyticsService._();

  /// Configures FlutterError and PlatformDispatcher error handlers in release mode.
  static void initialize() {
    if (!kReleaseMode) return;

    // Replace default Flutter error manager
    FlutterError.onError = (details) {
      if (_isIgnoredError(details.exception, details.library)) {
        return;
      }
      if (_isNetworkException(details.exception)) {
        FirebaseCrashlytics.instance.recordError(
          details.exception,
          details.stack,
          fatal: false,
        );
        return;
      }
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Replace default Flutter platform dispatcher error manager
    PlatformDispatcher.instance.onError = (error, stack) {
      if (_isIgnoredError(error, null)) {
        return true;
      }
      if (_isNetworkException(error)) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
        return true;
      }
      // Send error to Crashlytics
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

      // States that the error has been handled
      return true;
    };
  }

  static bool _isIgnoredError(dynamic exception, String? library) {
    final errorStr = exception.toString();
    if (exception is TickerCanceled ||
        errorStr.contains("This ticker was canceled") ||
        errorStr.contains("TickerCanceled") ||
        errorStr.contains("ProxyBillingActivity") ||
        errorStr.contains("GamesResolutionActivity")) {
      return true;
    }

    if (errorStr.contains("Loading interrupted")) return true;

    final isNetworkOrSocket =
        exception is SocketException ||
        exception is HttpException ||
        exception is HandshakeException ||
        errorStr.contains("SocketException") ||
        errorStr.contains("HttpException") ||
        errorStr.contains("HandshakeException") ||
        errorStr.contains("Software caused connection abort") ||
        errorStr.contains("Connection reset by peer") ||
        errorStr.contains("Connection refused") ||
        errorStr.contains("Host lookup failed") ||
        errorStr.contains("Connection closed") ||
        errorStr.contains("Network is unreachable") ||
        errorStr.contains("Operation not permitted") ||
        errorStr.contains("Bad file descriptor");

    if (isNetworkOrSocket &&
        (library == 'image resource service' ||
            errorStr.contains('googleusercontent.com') ||
            errorStr.contains('image_stream.dart') ||
            errorStr.contains('LanBeacon') ||
            errorStr.contains('LanDiscovery') ||
            errorStr.contains('lan_discovery.dart') ||
            errorStr.contains('Bad file descriptor') ||
            errorStr.contains('8888'))) {
      debugPrint("Crashlytics: Ignored network socket/http error");
      return true;
    }

    return false;
  }

  static bool _isNetworkException(dynamic exception) {
    return exception is SocketException ||
        exception is HttpException ||
        exception is HandshakeException;
  }
}
