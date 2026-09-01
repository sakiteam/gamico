import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/coins_store_poster.dart';
import 'package:gamico/commons/generics/gratification_poster.dart';
import 'package:gamico/commons/generics/special_offer_poster.dart';
import 'package:gamico/commons/generics/premium_poster.dart';
import 'package:gamico/commons/generics/ad_button.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinsPopup extends StatefulWidget {
  static int get coinsPopupIndex =>
      LocalStorageService.getInt("coins_popup_index") ?? 0;
  static set coinsPopupIndex(int value) =>
      LocalStorageService.setInt("coins_popup_index", value);

  final int? minimumRequiredCowries;

  const CoinsPopup({super.key, required this.minimumRequiredCowries});

  static Future<void> showCowriesPopup(
    BuildContext context, [
    int? minimumRequiredCowries,
  ]) async {
    await NavigationService.showPopup(
      context: context,
      builder: (_) =>
          CoinsPopup(minimumRequiredCowries: minimumRequiredCowries),
    );
  }

  @override
  State<CoinsPopup> createState() => _CoinsPopupState();
}

class _CoinsPopupState extends State<CoinsPopup> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();

    int initialIndex;

    final cowries = context.read<GamicoUserCubit>().state.user?.coins ?? 0;
    final gratificationEnabled =
        context.read<GratificationCubit>().state.gratificationEnabled;

    if (gratificationEnabled) {
      initialIndex = 0;
    } else if (widget.minimumRequiredCowries != null &&
        cowries < widget.minimumRequiredCowries!) {
      initialIndex = 1;
    } else {
      initialIndex = CoinsPopup.coinsPopupIndex;
    }

    pageController = PageController(initialPage: initialIndex);
    CoinsPopup.coinsPopupIndex = initialIndex;

    pageController.addListener(() {
      final currentIndex = pageController.page?.round() ?? 0;

      if (CoinsPopup.coinsPopupIndex != currentIndex) {
        CoinsPopup.coinsPopupIndex = currentIndex;

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.select(
      (PurchasesCubit purchasesCubit) => purchasesCubit.state.products,
    );

    final content = [
      const GamicoGratificationPoster(),
      if (products.isNotEmpty &&
          Gamico.instance.purchasesSettings?.classicPacks.isNotEmpty == true)
        GamicoCoinsStorePoster(
          minimumRequiredCoins: widget.minimumRequiredCowries,
        ),
      if (products.isNotEmpty &&
          Gamico.instance.purchasesSettings?.specialPacks.isNotEmpty == true)
        const GamicoSpecialOfferPoster(),
      if (context.read<GamicoUserCubit>().state.user?.premium != true)
        const GamicoPremiumPoster(),
    ];

    return GamicoPopup(
      pageController: pageController,
      pageControllerLength: content.length,
      additionalChild:
          Gamico.instance.admobSettings?.displayAdButton == false
              ? null
              : GamicoAdButton(
                onPressed: () async {
                  final admobCubit = context.read<AdmobCubit>();

                  await admobCubit.ensureRewardedAdLoaded();

                  admobCubit.showRewardedAd(() {
                    context.read<GamicoUserCubit>().incrementCowries();
                  });
                },
              ),
      child: PageView(
        controller: pageController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: content,
      ),
    );
  }
}
