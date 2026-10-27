import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/blocked_account_poster.dart';
import 'package:gamico/commons/generics/character.dart';
import 'package:gamico/commons/generics/only_one_pointer_recognizer_widget.dart';
import 'package:gamico/commons/generics/page_indicator.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/ink_fitted_box.dart';

class GamicoSimplePopup extends StatefulWidget {
  final Widget child;

  final Widget? topLeftWidget;
  final Widget? topRightWidget;

  final Widget? additionalChild;

  /// Painted over [background], across the whole sheet — its top padding
  /// included, which [child] never reaches. For a glow that has to run up to
  /// the sheet's real edge instead of being cut short above the content.
  final Widget? backgroundOverlay;

  final PageController? pageController;
  final int? pageControllerLength;
  final bool squarePageIndicators;

  static double topIconMargin = 0;

  static double watchButtonDefaultHeight = 60 * 450 / 400;
  static double watchButtonMargin = 24;
  static double get watchButtonFinalHeight =>
      watchButtonDefaultHeight + watchButtonMargin;
  static Widget background = Container(color: Colors.white);
  static Color pageIndicatorColor = Colors.white;

  final bool dismissible;
  final List<GamicoCharacterPosition>? characterPositions;

  /// Height of the popup content area in reference coordinates. Defaults to
  /// [LayoutService.referenceWidth] (the historical square-ish popup); pass a
  /// larger value when the content needs more vertical room (e.g. a full
  /// scoreboard that must be visible without scrolling).
  final double? customHeight;

  const GamicoSimplePopup({
    super.key,
    required this.child,
    this.topLeftWidget,
    this.topRightWidget,
    this.additionalChild,
    this.backgroundOverlay,
    this.pageController,
    this.pageControllerLength,
    this.squarePageIndicators = false,
    this.dismissible = true,
    this.characterPositions,
    this.customHeight,
  });

  @override
  State<GamicoSimplePopup> createState() => _GamicoSimplePopupState();
}

class _GamicoSimplePopupState extends State<GamicoSimplePopup> {
  List<GamicoCharacterPosition>? _characterPositions;
  CharacterCubit? _characterCubit;

  @override
  void initState() {
    super.initState();
    _characterCubit = context.read<CharacterCubit>();
  }

  @override
  void dispose() {
    if (_characterPositions != null) {
      _characterCubit?.deletePositionsList(_characterPositions!);
    }
    super.dispose();
  }

  void _syncCharacterPositions(List<GamicoCharacterPosition> positions) {
    if ("$_characterPositions" != "$positions") {
      _characterPositions ??= [];
      _characterPositions!.clear();
      _characterPositions!.addAll(positions);
      _characterCubit?.upsertPositionsList(_characterPositions!);
    }
  }

  /// Whether the focused field sits in this popup: only then is the keyboard
  /// this popup's to dodge. A keyboard still closing from the screen behind
  /// (showPopup unfocuses it), or an inset iOS never cleared, must not push
  /// the popup to the top of the screen.
  bool _ownsFocus() {
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null || !focused.mounted) return false;
    return focused.findAncestorStateOfType<_GamicoSimplePopupState>() == this;
  }

  @override
  Widget build(BuildContext context) {
    const topPadding = 24.0;
    final bottomPadding = max(36.0, MediaQuery.of(context).padding.bottom);

    final widgetCharacterPositions =
        widget.characterPositions ??
        [
          if (widget.topLeftWidget == null) GamicoCharacterPosition.centerLeft,
          if (widget.topRightWidget == null)
            GamicoCharacterPosition.centerRight,
        ];

    _syncCharacterPositions(widgetCharacterPositions);

    final blocked = context.select(
      (GamicoUserCubit userCubit) => userCubit.state.user?.blocked ?? false,
    );

    // Keyboard avoidance: the popup is anchored to the bottom of the screen,
    // so a text field inside it would sit behind the keyboard. Modal bottom
    // sheets do not reflow for `viewInsets`, so lift the whole popup by hand —
    // in REAL pixels (outside the FittedBox), and never further than the free
    // space above it, so the top of the popup can't be pushed off-screen.
    final mediaQuery = MediaQuery.of(context);

    final popupScaledHeight =
        (widget.customHeight ?? LayoutService.referenceWidth) +
        topPadding +
        bottomPadding +
        (widget.additionalChild != null
            ? GamicoSimplePopup.watchButtonFinalHeight
            : 0);

    final availableSpace = max(
      0.0,
      mediaQuery.size.height - popupScaledHeight * LayoutService.ratio,
    );

    // Rebuilt on every inset change, so focus is re-read as the keyboard moves.
    final keyboardLift = _ownsFocus()
        ? min(mediaQuery.viewInsets.bottom, availableSpace)
        : 0.0;

    return PopScope(
      canPop: widget.dismissible,
      child: OnlyOnePointerRecognizerWidget(
        child: DeferredPointerHandler(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, -keyboardLift, 0),
            width: double.infinity,
            height: double.infinity,
            child: InkFittedBox(
              child: Container(
                width: LayoutService.referenceWidth,
                height: LayoutService.referenceHeight,
                alignment: Alignment.center,
                child: OverflowBox(
                  maxWidth: LayoutService.scaledTotalWidth,
                  maxHeight: LayoutService.scaledTotalHeight,
                  child: Column(
                    children: [
                      // Clickable area
                      Expanded(
                        child: DeferPointer(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.dismissible
                                ? () {
                                    NavigationService.pop(context);
                                  }
                                : null,
                          ),
                        ),
                      ),

                      // Additional child
                      if (widget.additionalChild != null)
                        Center(
                          child: SizedBox(
                            height: GamicoSimplePopup.watchButtonFinalHeight,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: widget.dismissible
                                        ? () {
                                            NavigationService.pop(context);
                                          }
                                        : null,
                                  ),
                                ),
                                Center(
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      GamicoSimplePopup.watchButtonMargin,
                                    ),
                                    child:
                                        SizedBox(
                                              height: GamicoSimplePopup
                                                  .watchButtonFinalHeight,
                                              child: widget.additionalChild,
                                            )
                                            .animate()
                                            .slideY(begin: 1, end: 0)
                                            .then()
                                            .shake(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Concrete content
                      DeferPointer(
                        child: SizedBox(
                          width: double.infinity,
                          height:
                              (widget.customHeight ??
                                  LayoutService.referenceWidth) +
                              topPadding +
                              bottomPadding,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              GamicoSimplePopup.background,
                              if (widget.backgroundOverlay != null)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: widget.backgroundOverlay,
                                  ),
                                ),
                              Center(
                                child: SizedBox(
                                  width: LayoutService.referenceWidth,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: topPadding),
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            blocked
                                                ? const GamicoBlockedAccountPoster()
                                                : widget.child,
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: LayoutService
                                                      .optionButtonMargin,
                                                  top: GamicoSimplePopup
                                                      .topIconMargin,
                                                ),
                                                child: widget.topLeftWidget,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  right: LayoutService
                                                      .optionButtonMargin,
                                                  top: GamicoSimplePopup
                                                      .topIconMargin,
                                                ),
                                                child: widget.topRightWidget,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: bottomPadding,
                                        child:
                                            widget.pageController != null &&
                                                widget.pageControllerLength !=
                                                    null
                                            ? Center(
                                                child: GamicoPageIndicator(
                                                  controller:
                                                      widget.pageController!,
                                                  count: widget
                                                      .pageControllerLength!,
                                                  color: GamicoSimplePopup
                                                      .pageIndicatorColor,
                                                  square: widget
                                                      .squarePageIndicators,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
