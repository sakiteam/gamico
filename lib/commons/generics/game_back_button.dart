import 'package:flutter/material.dart';
import 'package:gamico/commons/services/navigation.dart';

class GamicoGameBackButton extends StatelessWidget {
  final Function(BuildContext context, void Function() onPressed) builder;

  const GamicoGameBackButton({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      () => NavigationService.maybePop(context),
    );
  }
}
