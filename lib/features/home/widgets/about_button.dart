import 'package:flutter/material.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/home/widgets/home_about_popup.dart';

class GamicoAboutButton extends StatelessWidget {
  final Widget Function(BuildContext context, void Function() onPressed)
  builder;

  /// Forwarded to [HomeAboutPopup.showShare].
  final bool showShare;

  const GamicoAboutButton({
    super.key,
    required this.builder,
    this.showShare = true,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, () {
      NavigationService.showPopup(
        context: context,
        builder: (_) {
          return HomeAboutPopup(showShare: showShare);
        },
      );
    });
  }
}
