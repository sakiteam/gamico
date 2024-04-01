import 'package:flutter/material.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/home/widgets/home_translation_popup.dart';

class GamicoTranslationButton extends StatelessWidget {
  final Widget Function(BuildContext context, void Function() onPressed)
      builder;

  const GamicoTranslationButton({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, () {
      NavigationService.showPopup(
        context: context,
        builder: (_) {
          return const HomeTranslationPopup();
        },
      );
    });
  }
}
