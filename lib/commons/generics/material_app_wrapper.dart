import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
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
