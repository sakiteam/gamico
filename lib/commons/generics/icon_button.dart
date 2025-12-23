import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/button.dart';

class GamicoIconButton extends StatelessWidget {
  final IconData icon;
  final void Function()? onPressed;
  final Color? color;

  const GamicoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GamicoButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        color: color ??
            (onPressed == null
                ? Colors.black.withAlpha(255 ~/ 2)
                : Colors.black),
        size: 32,
      ),
    );
  }
}
