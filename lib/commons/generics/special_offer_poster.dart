import 'dart:math';

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

  /// What the special pack's coins cost when bought as classic packs: the
  /// cheapest combination of classic packs adding up to exactly as many coins,
  /// or, when none does, those coins at the best classic per-coin rate.
  ///
  /// Null when the amounts are not configured, no classic price is known in
  /// the offer's currency, or the classic price is not higher than the offer —
  /// there is then no honest price to strike through.
  static double? _regularPrice(
    ProductDetails specialPack,
    List<ProductDetails> products,
  ) {
    final settings = Gamico.instance.purchasesSettings!;
    final target = settings.packsAmounts[specialPack.id];
    if (target == null || target <= 0) return null;

    // Coins → cheapest classic pack giving exactly that many.
    final classicPrices = <int, double>{};
    for (final id in settings.classicPacksIds) {
      final amount = settings.packsAmounts[id];
      final product = products.where((p) => p.id == id).firstOrNull;
      if (amount == null || amount <= 0 || product == null) continue;
      if (product.currencyCode != specialPack.currencyCode) continue;
      final known = classicPrices[amount];
      if (known == null || product.rawPrice < known) {
        classicPrices[amount] = product.rawPrice;
      }
    }
    if (classicPrices.isEmpty) return null;

    // cheapest[n]: cheapest way to get exactly n coins from classic packs.
    final cheapest = List<double?>.filled(target + 1, null);
    cheapest[0] = 0;
    for (var n = 1; n <= target; n++) {
      for (final MapEntry(key: amount, value: price) in classicPrices.entries) {
        if (amount > n) continue;
        final rest = cheapest[n - amount];
        if (rest == null) continue;
        final cost = rest + price;
        if (cheapest[n] == null || cost < cheapest[n]!) cheapest[n] = cost;
      }
    }

    final regular =
        cheapest[target] ??
        target *
            classicPrices.entries
                .map((entry) => entry.value / entry.key)
                .reduce(min);
    return regular > specialPack.rawPrice ? regular : null;
  }

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
                double? regularPrice;
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
                  regularPrice = _regularPrice(specialPack, state.products);
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
                            if (regularPrice != null)
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
                                          "${regularPrice.toStringAsFixed(2)} $packCurrency",
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
