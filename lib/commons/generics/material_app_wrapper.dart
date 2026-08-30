import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/services/database_shutdown.dart';
import 'package:gamico/commons/services/music.dart';

class GamicoMaterialAppWrapper extends StatefulWidget {
  final Widget child;

  const GamicoMaterialAppWrapper({
    super.key,
    required this.child,
  });

  static AppLifecycleState? state;

  @override
  State<GamicoMaterialAppWrapper> createState() =>
      _GamicoMaterialAppWrapperState();
}

class _GamicoMaterialAppWrapperState extends State<GamicoMaterialAppWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    GamicoMaterialAppWrapper.state = state;

    // The process is about to die: drop every Realtime Database listener now.
    // The native firebase_database observers otherwise stay attached until the
    // plugin is deallocated, and any event landing on the engine while it is
    // being destroyed crashes the app with an NSInternalInconsistencyException
    // out of `-[FlutterEngine sendOnChannel:]` (iOS/macOS).
    if (state == AppLifecycleState.detached) {
      GamicoDatabaseShutdown.cancelAll();
    } else if (state == AppLifecycleState.resumed) {
      // `detached` does not always kill the process on Android.
      GamicoDatabaseShutdown.reset();
    }

    final musicCubit = context.read<GamicoMusicCubit>();

    if (state == AppLifecycleState.resumed) {
      if (!MusicService.pausedByAd) {
        context.read<GratificationCubit>().loadWorldDate();
      }

      MusicService.pausedByAd = false;

      musicCubit.resume();
    } else {
      musicCubit.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
