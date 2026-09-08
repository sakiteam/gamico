import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/services/local_storage.dart';

/// Holds the loading screen until the account has resolved, so the app never
/// paints a home page over a user it does not have yet.
///
/// Without it the home page renders on whatever `state.user` happens to hold at
/// the first frame — historically the LocalStorage copy from the last session,
/// which is how a stale name or a stale coin count reached the screen. Waiting
/// here is what lets that copy stop being a source of truth: there is nothing
/// to flash, because nothing is painted until the real account is in.
///
/// "Resolved" is not "non-null". Three outcomes end the wait:
///  * the account loaded (`state.loaded`) — from the RTDB disk cache or the
///    server, either is fine for painting;
///  * there is no account to load — a player who has never signed in has an
///    empty [LocalStorageService.uid], and waiting for them would never end;
///  * [timeout] elapsed. Offline with a cold RTDB cache the listener never
///    fires at all, and a splash screen that can hang forever is worse than a
///    home page with empty stats. The app proceeds; the guards in
///    [GamicoUserCubit] keep that empty state from being written anywhere.
class GamicoAccountGate extends StatefulWidget {
  const GamicoAccountGate({
    super.key,
    required this.loading,
    required this.builder,
    this.timeout = const Duration(seconds: 5),
  });

  /// Shown while the account is still resolving.
  final WidgetBuilder loading;

  /// Shown once it has.
  final WidgetBuilder builder;

  /// Hard cap on the wait.
  final Duration timeout;

  @override
  State<GamicoAccountGate> createState() => _GamicoAccountGateState();
}

class _GamicoAccountGateState extends State<GamicoAccountGate> {
  Timer? _timer;
  bool _elapsed = false;

  @override
  void initState() {
    super.initState();

    // Nothing to wait for: don't even arm the timer.
    if (!LocalStorageService.authenticated) {
      _elapsed = true;
      return;
    }

    _timer = Timer(widget.timeout, () {
      if (!mounted || _elapsed) return;

      // Defensive: the listener below normally cancels this timer the moment
      // the account lands, but a resolution racing the deadline must not be
      // reported as a timeout either.
      if (!_stillWaiting) return;

      debugPrint(
        "⚠️ GamicoAccountGate: account still unresolved after "
        "${widget.timeout.inSeconds}s; entering the app without it",
      );

      setState(() => _elapsed = true);
    });
  }

  /// Whether the gate is still holding the loading screen right now.
  bool get _stillWaiting =>
      !context.read<GamicoUserCubit>().state.loaded &&
      LocalStorageService.authenticated;

  void _stopWaiting() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopWaiting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GamicoUserCubit, GamicoUserState>(
      listenWhen: (previous, current) => previous.loaded != current.loaded,
      listener: (context, state) {
        // The wait is over. Cancel the deadline rather than let it fire into a
        // home page that has been painted for seconds: this gate is the `home:`
        // widget, so it is never disposed and `dispose` would never get there.
        if (state.loaded) _stopWaiting();
      },
      buildWhen: (previous, current) => previous.loaded != current.loaded,
      builder: (context, state) {
        final waiting =
            !_elapsed && !state.loaded && LocalStorageService.authenticated;

        return waiting ? widget.loading(context) : widget.builder(context);
      },
    );
  }
}
