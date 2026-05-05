import 'package:gamico/commons/generics/coins_widget.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/timestamp.dart';
import 'package:gamico/commons/generics/disabler.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:gamico/languages/languages.dart';

class GamicoSpecialOfferPoster extends StatelessWidget {
  static double dashOffset = 0;
  static Color dashColor = Colors.white;

  const GamicoSpecialOfferPoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocBuilder<GratificationCubit, GratificationState>(
      builder: (context, gratificationState) {
        return BlocConsumer<InternetCubit, InternetState>(
          listener: (context, state) {
            if (state.connected) {
              context.read<GratificationCubit>().loadWorldDate();
            }
          },
          listenWhen: (previous, current) {
            return !previous.connected && current.connected;
          },
          builder: (context, state) {
            if (!state.connected) {
              return GamicoDialogPoster(
                icon: Icons.wifi_off,
                title: l.homeSpecialOfferPopupProblemTitle,
                description: l.homeGratificationPopupConnectionErrorDescription,
                simple: true,
                acceptationIcon: Icons.close,
                acceptationText: l.homeSpecialOfferPopupProblemClose,
              );
            }

            if (gratificationState.loading) {
              return GamicoPoster(
                iconWidget: CoinsWidget(
                  color: Colors.brown.shade700,
                  outlined: false,
                  size: 60,
                ),
                title: l.homeSpecialOfferPopupLoadingTitle,
                description: l.homeSpecialOfferPopupLoadingDescription,
                loading: true,
                padding: EdgeInsets.zero,
                expandContent: true,
              );
            }

            if (gratificationState.worldDateTimeDifference.inMinutes >= 5) {
              return GamicoDialogPoster(
                icon: Icons.schedule,
                title: l.homeSpecialOfferPopupTimestampTitle,
                description:
                    l.homeGratificationPopupIncorrectTimestampDescription,
                simple: true,
                acceptationIcon: Icons.close,
                acceptationText: l.homeSpecialOfferPopupClose,
              );
            }

            return BlocBuilder<PurchasesCubit, PurchasesState>(
              builder: (context, state) {
                final loading = state.status == PurchasesStatus.loading;
                final transactionLoading =
                    state.status == PurchasesStatus.transactionLoading;
                final transactionError =
                    state.status == PurchasesStatus.transactionFailure;

                String? specialPackId;
                ProductDetails? specialPack;

                String? packTitle;
                double? packPrice;
                String? packCurrency;

                if (loading == false && gratificationState.offerEnabled) {
                  final now = DateTime.now();
                  final todayAtMidnight = DateTime(
                    now.year,
                    now.month,
                    now.day,
                  );
                  final daysSinceReference = todayAtMidnight
                      .difference(DateTime(2022, 11, 1))
                      .inDays;
                  final offerIndex =
                      (daysSinceReference ~/ 3) %
                      Gamico.instance.purchasesSettings!.specialPacks.length;

                  specialPackId = Gamico
                      .instance
                      .purchasesSettings!
                      .specialPacksIds[offerIndex];

                  specialPack = state.products.firstWhere(
                    (element) => element.id == specialPackId,
                  );

                  packTitle = GamicoGlobalService.simplifyProductName(
                    specialPack.title,
                  );

                  packPrice = specialPack.rawPrice;
                  packCurrency = specialPack.currencySymbol;
                }

                return GamicoDialogPoster(
                  title: transactionError
                      ? l.homeSpecialOfferPopupErrorTitle
                      : (gratificationState.offerEnabled
                            ? (loading
                                  ? l.homeSpecialOfferPopupOfferLoadingTitle
                                  : l.homeSpecialOfferPopupOffsetLoadedTitle(
                                      packTitle,
                                    ))
                            : TimestampService.getCountdownString(
                                gratificationState.offerRemainingDuration,
                              )),
                  description: transactionError
                      ? l.homeSpecialOfferPopupErrorDescription
                      : (gratificationState.offerEnabled
                            ? (loading
                                  ? l.homeSpecialOfferPopupOfferLoadingDescription
                                  : l.homeSpecialOfferPopupOfferLoadedDescription)
                            : l.homeSpecialOfferPopupOfferDisabledDescription),
                  icon: transactionError ? Icons.error : null,
                  iconWidget: transactionError
                      ? null
                      : CoinsWidget(size: 60, color: Colors.brown.shade700),
                  loading:
                      (loading || transactionLoading) &&
                      gratificationState.offerEnabled,
                  simple: !gratificationState.offerEnabled || transactionError,
                  acceptationIcon: transactionError ? Icons.check : Icons.close,
                  acceptationText: transactionError
                      ? l.globalOK
                      : l.globalClose,
                  automaticClose: !transactionError,
                  onAccepted: () {
                    context.read<PurchasesCubit>().resetStatus();
                  },
                  expandContent: true,
                  content: gratificationState.offerEnabled && !transactionError
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //
                            GamicoDisabler(
                              disabled: true,
                              child: Stack(
                                children: [
                                  GamicoIconTextButton(
                                    onPressed: () {},
                                    iconWidget: CoinsWidget(
                                      size: 50,
                                      color: dashColor,
                                    ),
                                    // color: Colors.grey,
                                    // contentColor: Colors.black,
                                    text:
                                        "${((packPrice ?? 0) + 1).toStringAsFixed(2)} $packCurrency",
                                  ),
                                  Positioned(
                                    bottom:
                                        80 - 1, //24 * 450 / 400 - dashOffset,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Transform.translate(
                                        offset: Offset(0, dashOffset),
                                        child: Container(
                                          width: 100 * 450 / 400 - 32,
                                          height: 2,
                                          color: dashColor,
                                          // color: Colors.black.withAlpha(150),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //
                            GamicoIconTextButton(
                              color: ColorService.accentColor,
                              onPressed: () async {
                                if (specialPack != null) {
                                  context.read<PurchasesCubit>().purchase(
                                    specialPack,
                                  );
                                }
                              },
                              iconWidget: const CoinsWidget(
                                color: Colors.white,
                                size: 50,
                              ),
                              text:
                                  "${packPrice?.toStringAsFixed(2)} $packCurrency",
                            ),
                          ],
                        )
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }
}
