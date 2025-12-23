import 'package:games_services/games_services.dart';
import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
import 'package:gamico/commons/cubits/referral/referral_cubit.dart';
import 'package:gamico/commons/generics/coins_widget.dart';
import 'package:gamico/commons/generics/outlined_image.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/generics/outlined_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/user_photo.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';

class HomeProfilePopup extends StatelessWidget {
  const HomeProfilePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocBuilder<GamicoUserCubit, GamicoUserState>(
      builder: (__, state) {
        return GamicoPopup(
          topLeftWidget: BlocBuilder<ReferralCubit, ReferralState>(
            builder: (innerContext, state) {
              return IconButton(
                onPressed: () {
                  innerContext.read<AuthenticationCubit>().signOut();
                  NavigationService.pop(context);
                },
                icon: const GamicoOutlinedIcon(
                  Icons.logout,
                  size: 32,
                  color: Colors.red,
                ),
              );
            },
          ),
          topRightWidget: Stack(
            children: [
              IconButton(
                onPressed: null,

                //  () {
                //   //
                // },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Badge(
                      offset: const Offset(6, -4),
                      label: Text(
                        "${state.user?.trophies ?? 0}",
                        // color: Colors.blue,
                        // style: const TextStyle(color: Colors.brown),
                      ),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: GamicoOutlinedImage(
                          url: "assets/images/golden_crown.png",
                          // "assets/images/golden_crown.png",
                          width: 32,
                        ),
                      ),
                    ),
                    // Positioned(
                    //   bottom: -16,
                    //   left: 0,
                    //   right: 0,
                    //   child: Center(
                    //     child: Text(
                    //       "${state.user?.trophies ?? 0}",
                    //       // color: Colors.blue,
                    //       style: const TextStyle(color: Colors.brown),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          child: GamicoPoster(
            title: state.user?.name?.toUpperCase() ?? "",
            description: l.homeProfilePopupDescription,
            iconWidget: GamicoUserPhoto(state.user?.photo),
            expandContent: true,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GamicoIconTextButton(
                  color: Colors.brown.shade300,
                  iconData: Icons.emoji_events,
                  text: l.homeProfilePopupBestTacticians,
                  iconColor: Colors.white.withAlpha(75),
                  onPressed: () async {
                    await GamicoGlobalService.waitWhile(
                      () => !PlayService.gameServicesEnabled,
                    );
                    await Leaderboards.showLeaderboards(
                      androidLeaderboardID:
                          Gamico
                              .instance
                              .playSettings
                              ?.activePlayersLeaderboardId ??
                          "",
                      iOSLeaderboardID:
                          Gamico
                              .instance
                              .playSettings
                              ?.activePlayersLeaderboardId ??
                          "",
                    );
                  },
                ),
                GamicoIconTextButton(
                  color: Colors.brown.shade300,
                  iconWidget: CoinsWidget(
                    // color: Colors.blue,
                    size: 50,
                    color: Colors.white.withAlpha(75),
                  ),
                  text: l.homeProfilePopupBestCollectors,
                  onPressed: () async {
                    await GamicoGlobalService.waitWhile(
                      () => !PlayService.gameServicesEnabled,
                    );

                    await Leaderboards.showLeaderboards(
                      androidLeaderboardID:
                          Gamico
                              .instance
                              .playSettings
                              ?.inactivePlayersLeaderboardId ??
                          "",
                      iOSLeaderboardID:
                          Gamico
                              .instance
                              .playSettings
                              ?.inactivePlayersLeaderboardId ??
                          "",
                    );
                  },
                ),
                GamicoIconTextButton(
                  color: Colors.brown.shade300,
                  iconColor: Colors.white.withAlpha(75),
                  iconData: Icons.star,
                  text: l.homeProfilePopupCheckAchievements,
                  onPressed: () async {
                    await GamicoGlobalService.waitWhile(
                      () => !PlayService.gameServicesEnabled,
                    );
                    await Achievements.showAchievements();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
