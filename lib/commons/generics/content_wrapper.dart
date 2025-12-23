import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/scroll_behavior.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/generics/character.dart';
import 'package:gamico/commons/generics/only_one_pointer_recognizer_widget.dart';

class GamicoContentWrapper extends StatelessWidget {
  final Widget? child;
  final List<Widget>? decorations;
  final Widget? background;

  const GamicoContentWrapper({
    super.key,
    this.child,
    this.decorations,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    LayoutService.init(context);

    final blocBuilder = BlocBuilder<GamicoUserCubit, GamicoUserState>(
      buildWhen: (previous, current) {
        return previous.user?.blocked != current.user?.blocked;
      },
      builder: (context, userState) {
        final blocked = userState.user?.blocked ?? false;

        final content = ScrollConfiguration(
          behavior: const GamicoScrollBehavior(),
          child: OnlyOnePointerRecognizerWidget(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  // Backgound color
                  // Positioned.fill(
                  //   child: Material(
                  //     color: Colors.brown.shade300,
                  //   ),
                  // ),

                  // //
                  // const Positioned.fill(
                  //   child: Material(
                  //     color: Colors.brown,
                  //   ),
                  // ),

                  // Positioned.fill(
                  //   child: Container(
                  //     // color: Colors.white,
                  //     decoration: BoxDecoration(
                  //         gradient: LinearGradient(
                  //       begin: Alignment.topCenter,
                  //       end: Alignment.bottomCenter,
                  //       // stops: [
                  //       //   0.5,
                  //       //   0.6,
                  //       //   0.9,
                  //       // ],
                  //       colors: [
                  //         // Colors.red,
                  //         // ColorService.red.shade900,
                  //         Colors.brown,
                  //         Colors.brown.shade300,
                  //       ],
                  //     )),
                  //   ),
                  // ),

                  // Container(
                  //   child: background,
                  // ),
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
                                child: background,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Background 1
                  // Positioned.fill(
                  //   child: Opacity(
                  //     opacity: 0.25,
                  //     child: Image.asset(
                  //       "assets/images/erosion.jpg",
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),

                  // Background 2
                  // const Positioned.fill(
                  //   top: -20,
                  //   bottom: -20,
                  //   child: Opacity(
                  //     opacity: 0.5,
                  //     child: DynamicImage(
                  //       path: "assets/images/game_background.png",
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),

                  // True content
                  if (child != null) Positioned.fill(child: child!),

                  // Character
                  Positioned.fill(
                    child: FittedBox(
                      child: DeferredPointerHandler(
                        child: SizedBox(
                          // color: Colors.blue.withAlpha(100),
                          width: LayoutService.referenceWidth,
                          height: LayoutService.referenceHeight,
                          child: OverflowBox(
                            minWidth: 0,
                            minHeight: 0,
                            maxWidth: double.infinity,
                            maxHeight: double.infinity,
                            child: SizedBox(
                              // color: Colors.red,
                              width: LayoutService.scaledTotalWidth,
                              height: LayoutService.scaledTotalHeight,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ...(decorations ?? []),
                                  ...GamicoCharacterPosition.values.map(
                                    (e) => GamicoCharacter(position: e),
                                  ),
                                ],
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
          ),
        );

        if (blocked) {
          return ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
            child: AbsorbPointer(absorbing: blocked, child: content),
          );
        }

        return content;
      },
    );

    if (androidScreenshots) {
      return Center(
        child: SizedBox(
          width: LayoutService.realTotalWidth,
          height: LayoutService.realTotalHeight,
          child: blocBuilder,
        ),
      );
    }

    return blocBuilder;
  }
}
