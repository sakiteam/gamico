import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

typedef AnalyticsLogger = Future<void> Function({
  required String name,
  Map<String, Object>? parameters,
});

Future<void> logEvent({
  required String name,
  Map<String, Object>? parameters,
  AnalyticsLogger? logger,
}) async {
  if (!kReleaseMode) return;

  final effectiveLogger = logger ?? FirebaseAnalytics.instance.logEvent;

  return effectiveLogger(name: name, parameters: parameters);
}
