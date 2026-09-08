import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/languages/languages.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modal poster displayed when a user account is suspended or blocked.
class GamicoBlockedAccountPoster extends StatelessWidget {
  final String supportEmail;

  const GamicoBlockedAccountPoster({
    super.key,
    this.supportEmail = "sakihub@gmail.com",
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoPoster(
      icon: Icons.error,
      title: l.blockedAccountTitle,
      description: l.blockedAccountDescription,
      expandContent: true,
      content: Center(
        child: GamicoIconTextButton(
          text: l.blockedAccountContactSakiHub,
          color: ColorService.accentColor,
          iconData: Icons.mail,
          onPressed: () async {
            try {
              await launchUrl(Uri.parse("mailto:$supportEmail"));
            } catch (e) {
              debugPrint("Error launching support email: $e");
            }
          },
        ),
      ),
    );
  }
}
