import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/version.dart';
import 'package:gamico/commons/utilities/couple/couple_utility.dart';
import 'package:gamico/commons/utilities/share/gamico_share_utility.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/services/store.dart';
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

  Future<void> _safeLaunchUrl(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Failed to launch $url: $e");
    }
  }

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
          return Builder(
            builder: (btnContext) {
              return IconButton(
                onPressed: () {
                  try {
                    btnContext.read<GamicoMusicCubit>().playClickBruitage();
                  } catch (_) {}

                  String link = ""; // state.link;

                  if (link.isEmpty) {
                    if (Platform.isAndroid) {
                      link = Gamico.instance.storeSettings?.androidLink ?? "";
                    } else {
                      link = Gamico.instance.storeSettings?.iOSLink ?? "";
                    }
                  }

                  GamicoShareUtility.share(
                    context: btnContext,
                    text: l.homeAboutPopupShareText(link),
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
                StoreService.openStorePage();
              },
            ),
            GamicoIconTextButton(
              color: ColorService.aboutButtonColor,
              iconData: Icons.public,
              iconColor: ColorService.aboutIconColor,
              text: l.homeAboutPopupVisitWebstie,
              onPressed: () {
                _safeLaunchUrl("https://saki-hub.web.app");
              },
            ),
            GamicoIconTextButton(
              color: ColorService.aboutButtonColor,
              iconData: Icons.apps,
              text: l.homeAboutPopupDiscoverApps,
              iconColor: ColorService.aboutIconColor,
              onPressed: () {
                if (Platform.isAndroid) {
                  _safeLaunchUrl(
                    "https://play.google.com/store/apps/dev?id=8434106479316779165",
                  );
                } else {
                  _safeLaunchUrl(
                    "itms-apps://itunes.apple.com/developer/id1628421324",
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
