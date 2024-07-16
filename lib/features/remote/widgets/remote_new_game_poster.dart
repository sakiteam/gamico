import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';
import 'package:gamico/languages/languages.dart';

class RemoteNewGamePoster extends StatelessWidget {
  const RemoteNewGamePoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final animInit =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.animInit);
    final animGame =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.animGame);

    return GamicoPoster(
      animationTarget: animInit && !animGame ? 1 : 0,
      title: l.remoteNewGamePosterTitle,
      description: l.remoteNewGamePosterDescription,
      icon: Icons.public,
      content: GamicoIconTextButton(
        text: null,
        onPressed: () {
          context.read<RemoteCubit>().reset();
        },
        backgroundColor: Colors.brown,
        color: ColorService.accentColor,
        iconData: Icons.sports_esports,
      ),
    );
  }
}
