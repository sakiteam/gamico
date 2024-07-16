import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';

class GamicoButton extends StatelessWidget {
  final void Function(bool)? onDownChanged;
  final String? bruitage;
  final Widget child;
  final void Function()? onPressed;
  final BorderRadius? borderRadius;
  final bool ink;

  static const double defaultBorderRadius = 12;

  const GamicoButton({
    super.key,
    this.onDownChanged,
    this.bruitage,
    required this.child,
    required this.onPressed,
    this.borderRadius,
    this.ink = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // focusColor: Colors.green,
        // hoverColor: Colors.blue,
        overlayColor: ink ? null : WidgetStateProperty.all(Colors.transparent),
        onDoubleTap: () {},
        borderRadius:
            borderRadius ?? BorderRadius.circular(defaultBorderRadius),
        onTap: () {
          if (bruitage == null || bruitage!.isNotEmpty) {
            final musicCubit = context.read<GamicoMusicCubit>();

            switch (bruitage ?? "click") {
              case "click":
                musicCubit.playClickBruitage();
                break;

              case "lock":
                musicCubit.playLockBruitage();
                break;

              case "move":
                musicCubit.playMoveBruitage();
                break;
            }
          }

          onPressed?.call();
        },
        splashColor: Colors.black.withAlpha(50),
        highlightColor: Colors.black.withAlpha(25),
        onTapCancel: () {
          onDownChanged?.call(false);
        },
        onTapDown: (details) {
          onDownChanged?.call(true);
        },
        onTapUp: (details) {
          onDownChanged?.call(false);
        },
        child: child,
      ),
    );
  }
}
