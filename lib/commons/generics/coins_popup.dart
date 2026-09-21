import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/ad_button.dart';
import 'package:gamico/commons/generics/coins_popup_index_manager.dart';
import 'package:gamico/commons/generics/coins_store_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/gratification_poster.dart';
import 'package:gamico/commons/generics/premium_poster.dart';
import 'package:gamico/commons/generics/special_offer_poster.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/navigation.dart';

/// Modal dialog for store purchases, hourly rewards, special offers, and premium status.
class CoinsPopup extends StatefulWidget {
  static int get coinsPopupIndex => CoinsPopupIndexManager.savedIndex;
  static set coinsPopupIndex(int value) =>
      CoinsPopupIndexManager.savedIndex = value;

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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    final userCoins = context.read<GamicoUserCubit>().state.user?.coins ?? 0;
    final gratificationEnabled = context
        .read<GratificationCubit>()
        .state
        .gratificationEnabled;

    final initialIndex = CoinsPopupIndexManager.resolveInitialIndex(
      userCoins: userCoins,
      gratificationEnabled: gratificationEnabled,
      minimumRequiredCoins: widget.minimumRequiredCowries,
    );

    _pageController = PageController(initialPage: initialIndex);
    CoinsPopupIndexManager.savedIndex = initialIndex;

    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    final currentIndex = _pageController.page?.round() ?? 0;
    if (CoinsPopupIndexManager.savedIndex != currentIndex) {
      CoinsPopupIndexManager.savedIndex = currentIndex;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  Widget? _buildAdButton(BuildContext context) {
    if (Gamico.instance.admobSettings?.displayAdButton == false) return null;

    return GamicoAdButton(
      onPressed: () async {
        final admobCubit = context.read<AdmobCubit>();
        await admobCubit.ensureRewardedAdLoaded();
        admobCubit.showRewardedAd(() {
          context.read<GamicoUserCubit>().incrementCoins();
        });
      },
    );
  }

  List<Widget> _buildPages(BuildContext context) {
    final products = context.select(
      (PurchasesCubit purchasesCubit) => purchasesCubit.state.products,
    );

    return [
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
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(context);

    // Every page here reads the account. When the account goes away while the
    // popup is open there is nothing left to show and nothing to wait for, so
    // dismiss it.
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listenWhen: (previous, current) =>
          previous.authenticated && !current.authenticated,
      listener: (context, _) => NavigationService.pop(context),
      child: GamicoPopup(
        pageController: _pageController,
        pageControllerLength: pages.length,
        additionalChild: _buildAdButton(context),
        child: PageView(
          controller: _pageController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: pages,
        ),
      ),
    );
  }
}
