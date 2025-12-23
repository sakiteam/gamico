import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';

class GamicoGameReplayButton extends StatelessWidget {
  static Color defaultColor = Colors.blue;
  static Color defaultBackgroundColor = ColorService.backgroundBlue;

  final bool enabled;
  final Color? color;

  const GamicoGameReplayButton({super.key, this.enabled = true, this.color});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoIconTextButton(
      onPressed: !enabled
          ? null
          : () async {
              final gameMode = context.read<GamicoGameCubit>().state.gameMode;
              gameMode.manageReplay(context);
            },
      iconData: Icons.refresh,
      text: l.gamePopupReplay,
      color: color ?? defaultColor,
      backgroundColor: defaultBackgroundColor,
    );
  }
}
