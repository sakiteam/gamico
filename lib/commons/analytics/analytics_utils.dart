import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

Future<void> logEvent({
  required String name,
  Map<String, Object>? parameters,
}) async {
  if (!kReleaseMode) return;

  return FirebaseAnalytics.instance.logEvent(
    name: name,
    parameters: parameters,
  );
}
