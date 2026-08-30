import 'dart:async';

import 'package:flutter/foundation.dart';

/// Cancels every live Realtime Database listener before the Flutter engine is
/// torn down.
///
/// On iOS/macOS the firebase_database plugin keeps its native observers alive
/// until the plugin itself is deallocated. If a RTDB event lands while the
/// engine is already being destroyed, `-[FlutterEngine sendOnChannel:]` raises
/// an NSInternalInconsistencyException and the app crashes while quitting —
/// reported from `FLTFirebaseDatabaseObserveStreamHandler.onListen`.
///
/// Long-lived cubits register their listener-cancelling callback here, and the
/// app wrapper drains the registry on [AppLifecycleState.detached].
class GamicoDatabaseShutdown {
  GamicoDatabaseShutdown._();

  static final Map<Object, FutureOr<void> Function()> _handlers = {};

  static bool _shuttingDown = false;

  /// True once the app started tearing down: listeners must not resubscribe.
  static bool get shuttingDown => _shuttingDown;

  /// Registers (or replaces) the teardown callback of [owner].
  static void register(Object owner, FutureOr<void> Function() cancel) {
    _handlers[owner] = cancel;
  }

  static void unregister(Object owner) {
    _handlers.remove(owner);
  }

  /// Cancels every registered listener. Safe to call more than once.
  static Future<void> cancelAll() async {
    _shuttingDown = true;

    final handlers = List.of(_handlers.values);
    _handlers.clear();

    for (final cancel in handlers) {
      try {
        await cancel();
      } catch (e) {
        debugPrint("⚠️ GamicoDatabaseShutdown cancel error => $e");
      }
    }
  }

  /// The app survived a `detached` that did not kill the process (it happens on
  /// Android): allow listeners to resubscribe again.
  static void reset() {
    _shuttingDown = false;
  }
}
