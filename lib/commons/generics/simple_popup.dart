import 'dart:math';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/character.dart';
import 'package:gamico/commons/generics/page_indicator.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/generics/only_one_pointer_recognizer_widget.dart';
import 'package:gamico/languages/languages.dart';
import 'package:url_launcher/url_launcher.dart';

class GamicoSimplePopup extends StatefulWidget {
  final Widget child;

  final Widget? topLeftWidget;
  final Widget? topRightWidget;

  final Widget? additionalChild;

  final PageController? pageController;
  final int? pageControllerLength;

  static double topIconMargin = 0;

  static double watchButtonDefaultHeight = 60 * 450 / 400;
  static double watchButtonMargin = 20 * 450 / 400;
  static double get watchButtonFinalHeight =>
      watchButtonDefaultHeight + watchButtonMargin;
  static Widget background = Container(color: Colors.white);

  final bool dismissible;
  final List<GamicoCharacterPosition>? characterPositions;

  const GamicoSimplePopup({
    super.key,
    required this.child,
    this.topLeftWidget,
    this.topRightWidget,
    this.additionalChild,
    this.pageController,
    this.pageControllerLength,
    this.dismissible = true,
    this.characterPositions,
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

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    const topPadding = 24.0;
    final bottomPadding = max(36.0, MediaQuery.of(context).padding.bottom);

    final widgetCharacterPositions =
        widget.characterPositions ??
        [
          if (widget.topLeftWidget == null) GamicoCharacterPosition.centerLeft,
          if (widget.topRightWidget == null)
            GamicoCharacterPosition.centerRight,
        ];

    if ("$_characterPositions" != "$widgetCharacterPositions") {
      _characterPositions ??= [];

      _characterPositions!.clear();
      _characterPositions!.addAll(widgetCharacterPositions);

      _characterCubit?.upsertPositionsList(_characterPositions!);
    }

    final blocked = context.select(
      (GamicoUserCubit userCubit) => userCubit.state.user?.blocked ?? false,
    );

    return PopScope(
      canPop: widget.dismissible,
      child: OnlyOnePointerRecognizerWidget(
        child: DeferredPointerHandler(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
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
                            onTap:
                                widget.dismissible
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
                                    onTap:
                                        widget.dismissible
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
                                              height:
                                                  GamicoSimplePopup
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
                              LayoutService.referenceWidth +
                              topPadding +
                              bottomPadding,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              GamicoSimplePopup.background,
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
                                                ? GamicoPoster(
                                                  icon: Icons.error,
                                                  title: l.blockedAccountTitle,
                                                  description:
                                                      l.blockedAccountDescription,
                                                  expandContent: true,
                                                  content: Center(
                                                    child: GamicoIconTextButton(
                                                      text:
                                                          l.blockedAccountContactSakiHub,
                                                      color:
                                                          ColorService
                                                              .accentColor,
                                                      iconData: Icons.mail,
                                                      onPressed: () {
                                                        launchUrl(
                                                          Uri.parse(
                                                            "mailto:sakihub@gmail.com",
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                                : widget.child,
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left:
                                                      LayoutService
                                                          .optionButtonMargin,
                                                  top:
                                                      GamicoSimplePopup
                                                          .topIconMargin,
                                                ),
                                                child: widget.topLeftWidget,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  right:
                                                      LayoutService
                                                          .optionButtonMargin,
                                                  top:
                                                      GamicoSimplePopup
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
                                                ? GamicoPageIndicator(
                                                  controller:
                                                      widget.pageController!,
                                                  count:
                                                      widget
                                                          .pageControllerLength!,
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
