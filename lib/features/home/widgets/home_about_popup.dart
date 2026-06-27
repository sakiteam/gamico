import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/version.dart';
import 'package:gamico/commons/utilities/couple/couple_utility.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:gamico/commons/cubits/referral/referral_cubit.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/generics/outlined_icon.dart';
import 'package:gamico/commons/generics/info_line.dart';
import 'package:flutter/material.dart';
import 'package:gamico/languages/languages.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeAboutPopup extends StatelessWidget {
  const HomeAboutPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final couples = [
      GamicoCoupleUtility(l.homeAboutPopupImplementation, "Irié Bi Irié Alex"),
      GamicoCoupleUtility(l.homeAboutPopupMusic, "RGP Music Pack — SVL"),
      GamicoCoupleUtility(
        l.homeAboutPopupVersion,
        VersionService.versionString,
      ),
    ];

    return GamicoPopup(
      topLeftWidget: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          return IconButton(
            onPressed: () {
              try {
                context.read<GamicoMusicCubit>().playClickBruitage();
              } catch (_) {}

              String link = ""; // state.link;

              if (link.isEmpty) {
                if (Platform.isAndroid) {
                  link = Gamico.instance.storeSettings?.androidLink ?? "";
                } else {
                  link = Gamico.instance.storeSettings?.iOSLink ?? "";
                }
              }

              Share.share(
                l.homeAboutPopupShareText(link),
                subject: l.globalAppName,
              );
            },
            icon: const GamicoOutlinedIcon(
              Icons.share,
              size: 32,
              color: Colors.blue,
            ),
          );
        },
      ),
      child: GamicoPoster(
        icon: Icons.info,
        title: l.homeAbout,
        descriptionWidget: Column(
          children: couples
              .map((e) => GamicoInfoLine(coupleUtility: e))
              .toList(),
        ),
        expandContent: true,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GamicoIconTextButton(
              color: ColorService.aboutButtonColor,
              iconData: Icons.star,
              iconColor: ColorService.aboutIconColor,
              text: l.homeAboutPopupRateGame,
              onPressed: () {
                StoreRedirect.redirect();
              },
            ),
            GamicoIconTextButton(
              color: ColorService.aboutButtonColor,
              iconData: Icons.public,
              iconColor: ColorService.aboutIconColor,
              text: l.homeAboutPopupVisitWebstie,
              onPressed: () {
                launchUrl(Uri.parse("https://www.sakihub.com"));
              },
            ),
            GamicoIconTextButton(
              color: ColorService.aboutButtonColor,
              iconData: Icons.apps,
              text: l.homeAboutPopupDiscoverApps,
              iconColor: ColorService.aboutIconColor,
              onPressed: () {
                if (Platform.isAndroid) {
                  launchUrl(
                    Uri.parse(
                      "https://play.google.com/store/apps/dev?id=8434106479316779165",
                    ),
                  );
                } else {
                  launchUrl(
                    Uri.parse(
                      "itms-apps://itunes.apple.com/developer/id1628421324",
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
