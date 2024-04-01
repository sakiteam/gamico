import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/generics/character.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';

class GamicoContentContainer extends StatefulWidget {
  final bool enabled;

  final Widget? child;
  final Widget? safeChild;
  final Widget? foregroundChild;
  final Widget? backgroundChild;

  final bool characterAnimation;
  final List<GamicoCharacterPosition> characterPositions;

  const GamicoContentContainer({
    super.key,
    this.child,
    this.safeChild,
    this.enabled = true,
    this.foregroundChild,
    this.backgroundChild,
    this.characterAnimation = true,
    this.characterPositions = const [],
  });

  @override
  State<GamicoContentContainer> createState() => _GamicoContentContainerState();
}

class _GamicoContentContainerState extends State<GamicoContentContainer> {
  CharacterCubit? _characterCubit;

  List<GamicoCharacterPosition>? _characterPositions;

  @override
  void initState() {
    super.initState();

    _characterCubit = context.read<CharacterCubit>();
  }

  @override
  void dispose() {
    if (widget.characterAnimation) {
      if (_characterPositions != null) {
        _characterCubit?.deletePositionsList(_characterPositions!);
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.characterAnimation) {
      if ("$_characterPositions" != "${widget.characterPositions}") {
        _characterPositions ??= [];

        _characterPositions!.clear();
        _characterPositions!.addAll(widget.characterPositions);

        _characterCubit?.upsertPositionsList(_characterPositions!);
      }
    }

    return AbsorbPointer(
      absorbing: !widget.enabled,
      child: Center(
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            // Background
            if (widget.backgroundChild != null)
              Positioned.fill(
                child: FittedBox(
                  child: DeferredPointerHandler(
                    child: Container(
                      width: LayoutService.referenceWidth,
                      height: LayoutService.referenceHeight,
                      alignment: Alignment.center,
                      child: OverflowBox(
                        maxWidth: LayoutService.scaledTotalWidth,
                        maxHeight: LayoutService.scaledTotalHeight,
                        child: DeferPointer(
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: widget.backgroundChild,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Child
            if (widget.child != null)
              Positioned.fill(
                child: FittedBox(
                  child: SizedBox(
                    width: LayoutService.referenceWidth,
                    height: LayoutService.referenceHeight,
                    child: widget.child,
                  ),
                ),
              ),

            // Safe
            if (widget.safeChild != null)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: LayoutService.realUselessSpacing.top,
                    bottom: LayoutService.realUselessSpacing.bottom,
                  ),
                  child: FittedBox(
                    child: DeferredPointerHandler(
                      child: Container(
                        width: LayoutService.referenceWidth,
                        height: LayoutService.referenceHeight,
                        alignment: Alignment.center,
                        child: OverflowBox(
                          maxWidth: LayoutService.scaledUsefulWidth,
                          maxHeight: LayoutService.scaledUsefulHeight,
                          child: DeferPointer(
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: widget.safeChild,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Foreground
            if (widget.foregroundChild != null)
              Positioned.fill(
                child: FittedBox(
                  child: DeferredPointerHandler(
                    child: Container(
                      width: LayoutService.referenceWidth,
                      height: LayoutService.referenceHeight,
                      alignment: Alignment.center,
                      child: OverflowBox(
                        maxWidth: LayoutService.scaledTotalWidth,
                        maxHeight: LayoutService.scaledTotalHeight,
                        child: DeferPointer(
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: widget.foregroundChild,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
