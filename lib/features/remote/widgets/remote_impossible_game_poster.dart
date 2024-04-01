import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/coins_widget.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';
import 'package:gamico/languages/languages.dart';

class RemoteImpossibleGamePoster extends StatelessWidget {
  const RemoteImpossibleGamePoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final animInit =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.animInit);
    final animGame =
        context.select((RemoteCubit remoteCubit) => remoteCubit.state.animGame);

    return GamicoPoster(
      animationTarget: animInit && !animGame ? 1 : 0,
      title: l.remoteImpossibleGamePosterTitle,
      description: l.remoteImpossibleGamePosterDescription(
          Gamico.instance.gameSettings.playMinimumCowries),
      iconWidget: CoinsWidget(
        color: Colors.brown.shade700,
        size: 60,
        outlined: false,
      ),
      content: const GamicoIconTextButton(
        text: null,
        iconData: Icons.sports_esports,
        onPressed: null,
      ),
    );
  }
}
