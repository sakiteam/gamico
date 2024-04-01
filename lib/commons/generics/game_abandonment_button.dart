import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

class GamicoGameAbandonmentButton extends StatelessWidget {
  final Function(
    BuildContext context,
    void Function()? onPressed,
  ) builder;

  const GamicoGameAbandonmentButton({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Holds whether it is impossible to abandon the game
    final abandonmentImpossible = context.select(
        (GamicoGameCubit gameCubit) => gameCubit.state.abandonmentImpossible);

    // Concrete content
    return builder(
      context,
      abandonmentImpossible
          ? null
          : () {
              // Reference to languages
              final l = GamicoLanguages.of(context);

              NavigationService.showPopup(
                context: context,
                builder: (_) {
                  return GamicoPopup(
                    child: GamicoDialogPoster(
                      icon: Icons.warning,
                      title: l.gameAbandonmentButtonTitle,
                      description: l.gameAbandonmentButtonDescription,
                      acceptationText: l.gameAbandonmentButtonAbandon,
                      acceptationIcon: Icons.handshake_outlined,
                      onAccepted: () {
                        context.read<GamicoGameCubit>().giveUp();
                      },
                    ),
                  );
                },
              );
            },
    );
  }
}
