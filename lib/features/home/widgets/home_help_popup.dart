import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/popup_button.dart';
import 'package:gamico/features/home/widgets/home_help_popup_wooden_button.dart';

class HomeHelpPopup extends StatefulWidget {
  final void Function(dynamic) onLessonPressed;

  const HomeHelpPopup({
    super.key,
    required this.onLessonPressed,
  });

  @override
  State<HomeHelpPopup> createState() => _HomeHelpPopupState();
}

class _HomeHelpPopupState extends State<HomeHelpPopup> {
  final pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GamicoPopup(
      characterPositions: const [],
      additionalChild: SizedBox(
        width: GamicoPopupButton.defaultWidth,
        // padding: const EdgeInsets.only(
        //   bottom: CustomPopup.watchButtonMargin,
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: HomeHelpPopupWoodenButton(
                lesson: jsonDecode(""),
                onPressed: widget.onLessonPressed,
              ),
            ),
            Expanded(
              child: HomeHelpPopupWoodenButton(
                lesson: jsonDecode(""),
                onPressed: widget.onLessonPressed,
              ),
            ),
            Expanded(
              child: HomeHelpPopupWoodenButton(
                lesson: jsonDecode(""),
                onPressed: widget.onLessonPressed,
              ),
            ),
          ],
        ),
      ),
      child: const SizedBox(),
    );
  }
}
