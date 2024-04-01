import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGamePassButton extends StatelessWidget {
  final Function(
    BuildContext context,
    void Function()? onPressed,
  ) builder;

  const GamicoGamePassButton({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final over =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.over);

    return builder(
      context,
      over
          ? null
          : () {
              NavigationService.showPopup(
                context: context,
                builder: (_) {
                  return GamicoPopup(
                    child: GamicoDialogPoster(
                      icon: Icons.fast_forward,
                      title: l.gamePassButtonPopupTitle,
                      description: l.gamePassButtonPopupDescription,
                      acceptationIcon: Icons.fast_forward,
                      acceptationText: l.gamePassButtonPopupPass,
                      onAccepted: () {
                        context
                            .read<GamicoTutorialGameCubit>()
                            .declareWinnerByPass();
                      },
                    ),
                  );
                },
              );
            },
    );
  }
}
