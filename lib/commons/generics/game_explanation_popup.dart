import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGameExplanationPopup extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? descriptionWidget;

  const GamicoGameExplanationPopup({
    super.key,
    this.title,
    this.description,
    this.descriptionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoPopup(
      characterPositions: const [],
      dismissible: false,
      child: GamicoDialogPoster(
        title: title,
        description: description,
        descriptionWidget: descriptionWidget,
        simple: true,
        acceptationText: l.gameCardsSummaryPlay,
        acceptationIcon: Icons.sports_esports,
        onAccepted: () {
          final gameCubit = context.read<GamicoGameCubit>();

          gameCubit.startGame();

          NavigationService.pop(context);
        },
      ),
    );
  }
}
