import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/coins_widget.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/formatting.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/purchase_button.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/languages/languages.dart';

class GamicoCoinsStorePoster extends StatelessWidget {
  final int? minimumRequiredCoins;

  const GamicoCoinsStorePoster({
    super.key,
    required this.minimumRequiredCoins,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final purchasesStatus = context
        .select((PurchasesCubit purchasesCubit) => purchasesCubit.state.status);
    final purchasesProducts = context.select(
        (PurchasesCubit purchasesCubit) => purchasesCubit.state.products);
    final cowries = context.select(
            (GamicoUserCubit userCubit) => userCubit.state.user?.coins) ??
        0;

    final transactionLoading =
        purchasesStatus == PurchasesStatus.transactionLoading;
    final transactionError =
        purchasesStatus == PurchasesStatus.transactionFailure;

    String? title;
    String? description;

    final formattedCowries = FormattingService.formatNumber(cowries);

    if (minimumRequiredCoins != null) {
      if (cowries == 0) {
        title = l.homeCowriesStoreZeroCowrieTitle;
      } else if (cowries == 1) {
        title = l.homeCowriesStoreOneCowriesTitle;
      }

      if (cowries > 1) {
        title = l.homeCowriesStoreCowriesCount(formattedCowries);
      }

      if (cowries == minimumRequiredCoins) {
        description = l.homeCowriesStoreNotEnoughCowriesDescription;
      } else {
        if (minimumRequiredCoins == 1) {
          description = l.homeCowriesStoreMiniOne;
        } else {
          description = l.homeCowriesStoreMiniMulti(minimumRequiredCoins ?? 0);
        }
      }
    }

    return GamicoPoster(
      iconWidget: transactionError
          ? Icon(Icons.error, size: 60, color: Colors.brown.shade700)
          : CoinsWidget(
              color: Colors.brown.shade700, outlined: false, size: 60),
      title: title ??
          (transactionError
              ? l.homeCowriesStoreTransactionErrorTitle
              : l.homeCowriesStoreCowriesCount(formattedCowries)),
      description: description ??
          (transactionError
              ? l.homeCowriesStoreTransactionErrorDescription
              : l.homeCowriesStoreEnoughCowriesDescription),
      expandContent: true,
      content: Center(
        child: transactionError
            ? GamicoIconTextButton(
                text: transactionError ? l.globalOK : l.globalRefresh,
                color: ColorService.primaryColor,
                iconData: transactionError ? Icons.check : Icons.refresh,
                onPressed: () {
                  context.read<PurchasesCubit>().resetStatus();
                },
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: purchasesProducts
                    .where((element) =>
                        Gamico.instance.purchasesSettings?.classicPacksIds
                            .contains(element.id) ==
                        true)
                    .map((productDetail) {
                  return GamicoPurchaseButton(productDetails: productDetail);
                }).toList(),
              ),
      ),
      loading: purchasesStatus == PurchasesStatus.loading || transactionLoading,
    );
  }
}
