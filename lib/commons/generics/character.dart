import 'dart:io';
import 'dart:math';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/commons/services/layout.dart';

enum GamicoCharacterPosition {
  topLeft,
  topRight,
  //
  centerLeft,
  centerRight,
  //
  bottomLeft,
  bottomRight,
  bottomCenter,
  //
  bottomLeftExtreme,
  bottomRightExtreme,
}

class GamicoCharacter extends StatefulWidget {
  final GamicoCharacterPosition position;

  static const double size = 150 * 450 / 400;

  const GamicoCharacter({super.key, required this.position});

  @override
  State<GamicoCharacter> createState() => _GamicoCharacterState();
}

class _GamicoCharacterState extends State<GamicoCharacter> {
  late bool flip;

  late double angle;

  late Alignment alignment;

  /// Offset to position the image perfectly
  late Offset spriteOffset;

  /// Offset to make the image visible
  late Offset visibleOffset;

  /// Offfset based on the image already well placed
  late Offset invisibleOffset;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    _init();

    return BlocBuilder<CharacterCubit, CharacterState>(
      builder: (context, state) {
        // Set visibility according to position
        final visible =
            state.position == widget.position && state.animation != null;

        // Initial offset
        Offset offset;

        if (visible) {
          offset = visibleOffset + spriteOffset;
        } else {
          offset = visibleOffset + invisibleOffset + spriteOffset;
        }

        offset *= 450 / 400;

        // Concrete widget
        return Align(
          alignment: alignment,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            transform: Matrix4.translationValues(offset.dx, offset.dy, 0),
            width: GamicoCharacter.size,
            height: GamicoCharacter.size,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: angle,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(flip ? pi : 0),
                child: Stack(
                  children: [
                    IgnorePointer(
                      child: SizedBox(
                        width: GamicoCharacter.size,
                        height: GamicoCharacter.size,
                        // color: Colors.red.withAlpha(100),
                        child: state.animation == null
                            ? null
                            :
                            // ColorFiltered(
                            //     colorFilter: ColorFilter.mode(
                            //       Colors.orange,
                            //       BlendMode.modulate,
                            //     ),
                            //     child: Image.asset(
                            //       "assets/images/tree.png",
                            //     ),
                            //   ),

                            SpriteAnimationWidget(
                                animation: state.animation!,
                                animationTicker:
                                    state.animation!.createTicker(),
                                playing:
                                    visible && !(kDebugMode && Platform.isIOS),
                              ),
                      ),
                    ),
                    SizedBox(
                      width: GamicoCharacter.size,
                      height: GamicoCharacter.size,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: DeferPointer(
                              child: GestureDetector(
                                onTap: () {
                                  context
                                      .read<CharacterCubit>()
                                      .nullifyPosition();
                                },
                                child: Container(
                                  width: 70,
                                  height: 145,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: DeferPointer(
                              child: GestureDetector(
                                onTap: () {
                                  context
                                      .read<CharacterCubit>()
                                      .nullifyPosition();
                                },
                                child: Container(
                                  width: 74 * 450 / 400,
                                  height: 51.5 * 450 / 400,
                                  margin: const EdgeInsets.only(
                                    bottom: 16 * 450 / 400,
                                    right: 1 * 450 / 400,
                                    top: 2.5 * 450 / 400,
                                  ),
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _init() {
    const size = GamicoCharacter.size;

    switch (widget.position) {
      case GamicoCharacterPosition.topLeft:
        alignment = Alignment.topLeft;
        visibleOffset = Offset(
          0,
          LayoutService.optionButtonSize + LayoutService.optionButtonMargin * 2,
        );
        invisibleOffset = const Offset(
          -size,
          0,
        );
        flip = false;
        angle = (45) * pi / 180;
        spriteOffset = const Offset(-50, 0);
        break;

      case GamicoCharacterPosition.topRight:
        alignment = Alignment.topRight;
        visibleOffset = Offset(
          0,
          LayoutService.optionButtonSize + LayoutService.optionButtonMargin * 2,
        );
        invisibleOffset = const Offset(
          size,
          0,
        );
        flip = true;
        angle = (360 - 45) * pi / 180;
        spriteOffset = const Offset(50, 0);
        break;

      case GamicoCharacterPosition.centerLeft:
        alignment = Alignment.centerLeft;
        visibleOffset = const Offset(0, 0);
        invisibleOffset = const Offset(-size, 0);
        flip = false;
        angle = (45) * pi / 180;
        spriteOffset = const Offset(-50, 0);
        break;

      case GamicoCharacterPosition.centerRight:
        alignment = Alignment.centerRight;
        visibleOffset = const Offset(0, 0);
        invisibleOffset = const Offset(size, 0);
        flip = true;
        angle = (360 - 45) * pi / 180;
        spriteOffset = const Offset(50, 0);
        break;

      case GamicoCharacterPosition.bottomLeft:
        alignment = Alignment.bottomLeft;
        visibleOffset = Offset(
          0,
          -LayoutService.optionButtonSize -
              LayoutService.optionButtonMargin * 2,
        );
        invisibleOffset = const Offset(
          -size,
          0,
        );
        flip = true;
        angle = (47) * pi / 180;
        spriteOffset = const Offset(-50, 0);
        break;

      case GamicoCharacterPosition.bottomRight:
        alignment = Alignment.bottomRight;

        visibleOffset = Offset(
          0,
          -LayoutService.optionButtonSize -
              LayoutService.optionButtonMargin * 2,
        );
        invisibleOffset = const Offset(
          size,
          0,
        );
        flip = false;
        angle = (360 - 47) * pi / 180;
        spriteOffset = const Offset(50, 0);
        break;

      case GamicoCharacterPosition.bottomLeftExtreme:
        alignment = Alignment.bottomLeft;
        visibleOffset = const Offset(0, 0);
        invisibleOffset = const Offset(-size, size);
        flip = false;
        angle = (30) * pi / 180;
        spriteOffset = const Offset(-40, 15);
        break;

      case GamicoCharacterPosition.bottomRightExtreme:
        alignment = Alignment.bottomRight;
        visibleOffset = const Offset(0, 0);
        invisibleOffset = const Offset(size, size);
        flip = true;
        angle = (360 - 30) * pi / 180;
        spriteOffset = const Offset(40, 15);
        break;

      case GamicoCharacterPosition.bottomCenter:
        alignment = Alignment.bottomCenter;
        visibleOffset = const Offset(0, 0);
        invisibleOffset = const Offset(0, size);
        flip = false;
        angle = 0;
        spriteOffset = const Offset(0, 20);
        break;
    }
  }
}
