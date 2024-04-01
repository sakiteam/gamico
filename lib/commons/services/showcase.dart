// import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/showcase/showcase_cubit.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/generics/shape_clipper.dart';
// import 'package:gamico/commons/widgets/custom_card.dart';
import 'package:gamico/commons/generics/showcase_tooltip.dart';
// import 'package:gamico/commons/widgets/option_button.dart';
// import 'package:gamico/commons/widgets/big_container_decoration.dart';
// import 'package:gamico/commons/widgets/option_button.dart';
import 'package:gamico/commons/generics/showcase_widget.dart';
// import 'package:gamico/features/home/pages/home_page.dart';
// import 'package:gamico/features/home/widgets/home_card_presentation.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect get bounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();

    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return Rect.zero;
    }
  }
}

class ShowcaseService {
  static bool get shown =>
      LocalStorageService.getBool("showcase_shown") ?? false;
  static set shown(bool value) {
    LocalStorageService.setBool("showcase_shown", value);
  }

  static bool active = false;
  static OverlayEntry? activeOverlayEntry;
  static int currentIndex = 0;

  // static List<Rect> get rects => [
  //       multiplayerButtonRect,
  //       singleplayerButtonRect,
  //       cardPresentationRect,
  //       progressOptionButtonRect,
  //       cardOptionButtonRect,
  //     ];

  static List<GlobalKey> get keys => [
        multiplayerButtonKey,
        singleplayerButtonKey,
        cardPresentationKey,
        progressOptionButtonKey,
        cardOptionButtonKey,
      ];

  static final GlobalKey progressOptionButtonKey = GlobalKey();
  static final GlobalKey cardOptionButtonKey = GlobalKey();
  static final GlobalKey cardPresentationKey = GlobalKey();
  static final GlobalKey multiplayerButtonKey = GlobalKey();
  static final GlobalKey singleplayerButtonKey = GlobalKey();

  // static Rect get cardPresentationRect => Rect.fromLTWH(
  //       cardPresentationKey.bounds.left -
  //           BigContainerDecoration.woodSize * GlobalService.ratio,
  //       cardPresentationKey.bounds.top -
  //           BigContainerDecoration.woodSize * GlobalService.ratio,
  //       HomeCardPresentation.cardWoodedWidth,
  //       HomeCardPresentation.cardWoodedHeight,
  //     );

  // //
  // static Rect get multiplayerButtonRect => Rect.fromLTWH(
  //       multiplayerButtonKey.bounds.left,
  //       multiplayerButtonKey.bounds.top,
  //       HomePage.playerButtonWidth,
  //       HomePage.playerButtonHeight,
  //     );
  // static Rect get singleplayerButtonRect => Rect.fromLTWH(
  //       singleplayerButtonKey.bounds.left,
  //       singleplayerButtonKey.bounds.top,
  //       HomePage.playerButtonWidth,
  //       HomePage.playerButtonHeight,
  //     );

  // //
  // static Rect get progressOptionButtonRect => Rect.fromLTWH(
  //       progressOptionButtonKey.bounds.left - OptionButton.showcaseOffset,
  //       progressOptionButtonKey.bounds.top - OptionButton.showcaseOffset,
  //       OptionButton.trueWidth,
  //       OptionButton.trueHeight,
  //     );
  // static Rect get cardOptionButtonRect => Rect.fromLTWH(
  //       cardOptionButtonKey.bounds.left - OptionButton.showcaseOffset,
  //       cardOptionButtonKey.bounds.top - OptionButton.showcaseOffset,
  //       OptionButton.trueWidth,
  //       OptionButton.trueHeight,
  //     );

  static void show(BuildContext context) {
    context.read<ShowcaseCubit>().setActive(true);

    OverlayState? overlayState = Overlay.of(context);

    final activeKey = keys[currentIndex];
    final activeShowcaseWidget =
        activeKey.currentWidget as GamicoShowcaseWidget;

    final activeRect = Rect.fromLTWH(
      activeKey.bounds.left + activeShowcaseWidget.left,
      activeKey.bounds.top + activeShowcaseWidget.top,
      activeShowcaseWidget.width * LayoutService.ratio,
      activeShowcaseWidget.height * LayoutService.ratio,
    );

    activeOverlayEntry = OverlayEntry(
      builder: (context) {
        const padding = 8.0;
        const double arrowHeight = 20;

        final arrowContainerWidth = activeRect.width + 2 * padding;
        final arrowContainerLeft = activeRect.left - padding;
        final arrowContainerTop =
            activeRect.top + activeRect.height + 32 - arrowHeight / 2;

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: GamicoShapeClipper(
                  area: activeRect,
                  // isCircle: true,
                  //widget.targetShapeBorder is CircleBorder,
                  radius: (activeShowcaseWidget.borderRadius ??
                          BorderRadius.circular(12)) *
                      LayoutService.ratio,
                  overlayPadding: const EdgeInsets.all(padding)
                  //  _isScrollRunning
                  //     ? BorderRadius.zero
                  //     : widget.targetBorderRadius,
                  // overlayPadding:
                  //     _isScrollRunning ? EdgeInsets.zero : widget.targetPadding,
                  ),
              // borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.black.withAlpha(150),
                // alignment: Alignment.bottomCenter,
              ),
            ),
            GamicoShowcaseTooltip(
              arrowContainerTop: arrowContainerTop,
              arrowContainerLeft: arrowContainerLeft,
              arrowContainerWidth: arrowContainerWidth,
              arrowHeight: arrowHeight,
              activeRect: activeRect,
              activeShowcaseWidget: activeShowcaseWidget,
            )
                .animate(
                  onPlay: kDebugMode
                      ? null
                      : (controller) =>
                          controller.loop(count: 5, reverse: true),
                )
                .slideY(
                  begin: -0.005,
                  end: 0.005,
                  curve: Curves.ease,
                  duration: 2.5.seconds,
                ),
            GestureDetector(
              // color: Colors.red,
              // onLongPress: () {},
              onTap: () {
                activeOverlayEntry?.remove();
                currentIndex++;

                if (currentIndex < keys.length) {
                  show(context);
                } else {
                  context.read<ShowcaseCubit>().setActive(false);
                  ShowcaseService.shown = true;
                }
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(activeOverlayEntry!);
  }
}
