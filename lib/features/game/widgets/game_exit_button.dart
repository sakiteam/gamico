import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGameExitButton extends StatelessWidget {
  const GamicoGameExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoIconTextButton(
      onPressed: () async {
        final gameCubit = context.read<GamicoGameCubit>();

        NavigationService.pop(context);

        gameCubit.setBackActive(true);
      },
      iconData: Icons.arrow_back,
      text: l.globalExit,
    );
  }
}
