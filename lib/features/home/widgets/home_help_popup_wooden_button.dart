import 'package:flutter/material.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/button.dart';
import 'package:gamico/commons/generics/outlined_text.dart';
import 'package:gamico/commons/generics/popup_button.dart';
import 'package:gamico/languages/languages.dart';

class HomeHelpPopupWoodenButton extends StatelessWidget {
  final dynamic lesson;
  final void Function(dynamic) onPressed;

  const HomeHelpPopupWoodenButton({
    super.key,
    required this.lesson,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return SizedBox(
      // foregroundColor: Colors.blue,
      // onPressed: () {},
      height: GamicoPopupButton.defaultHeight,
      width: (GamicoPopupButton.defaultWidth) / 3,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/wood_piece.png",
              fit: BoxFit.fill,
            ),
          ),
          Positioned.fill(
            child: GamicoButton(
              bruitage: "click",
              borderRadius: BorderRadius.zero,
              child: Padding(
                // color: Colors.blue,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GamicoOutlinedText(
                      "${l.globalLesson} ${lesson.index + 1} :",
                      color: Colors.white,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    GamicoOutlinedText(
                      lesson.suffix,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              onPressed: () {
                NavigationService.pop(context);
                onPressed(lesson);
              },
            ),
          ),
          // IronDecoration(
          //   height: PopupButton.defaultHeight,
          //   width: (PopupButton.defaultWidth) / 3,
          // ),
        ],
      ),
    );
  }
}
