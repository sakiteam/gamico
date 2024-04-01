import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';
import 'package:gamico/languages/languages.dart';

class RemoteSearchPoster extends StatelessWidget {
  const RemoteSearchPoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final animInit =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.animInit);
    final animGame =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.animGame);

    return GamicoPoster(
      animationTarget: animInit && !animGame ? 1 : 0,
      title: l.remoteSearchPosterTitle,
      description: l.remoteSearchPosterDescription,
      icon: Icons.sports_esports,
      loading: true,
      padding: EdgeInsets.zero,
    );
  }
}
