import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:gamico/languages/languages.dart';

class GamicoPremiumPoster extends StatelessWidget {
  const GamicoPremiumPoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocBuilder<PurchasesCubit, PurchasesState>(
      builder: (context, state) {
        final loading = state.status == PurchasesStatus.loading;
        final transactionLoading =
            state.status == PurchasesStatus.transactionLoading;
        final transactionError =
            state.status == PurchasesStatus.transactionFailure;
        
        final premiumProductId = Gamico.instance.purchasesSettings?.premiumProductId;

        ProductDetails? premiumPack;
        String? packPrice;

        if (loading == false && premiumProductId != null) {
          try {
            premiumPack = state.products.firstWhere(
              (element) => element.id == premiumProductId,
            );
            packPrice = premiumPack.price; // Or rawPrice if we want to format ourselves
          } catch (_) {
            // Not found
          }
        }

        return GamicoDialogPoster(
          title: transactionError
              ? l.homeSpecialOfferPopupErrorTitle
              : l.premiumPopupTitle,
          description: transactionError
              ? l.homeSpecialOfferPopupErrorDescription
              : l.premiumPopupDescription,
          icon: transactionError ? Icons.error : Icons.workspace_premium,
          loading: loading || transactionLoading,
          simple: transactionError || premiumPack == null,
          acceptationIcon: transactionError ? Icons.check : Icons.close,
          acceptationText: transactionError ? l.globalOK : l.globalClose,
          automaticClose: !transactionError,
          onAccepted: () {
            context.read<PurchasesCubit>().resetStatus();
          },
          expandContent: true,
          content: !transactionError && premiumPack != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GamicoIconTextButton(
                      color: ColorService.accentColor,
                      onPressed: () async {
                        // Non-consumable: buying it as a consumable lets
                        // Google Play consume it, and restore then finds
                        // nothing on Android.
                        context.read<PurchasesCubit>().buyPremium();
                      },
                      iconData: Icons.star,
                      iconColor: Colors.white,
                      text: packPrice ?? "",
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
