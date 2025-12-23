import 'package:gamico/commons/generics/coins_widget.dart';
import 'package:gamico/commons/generics/disabler.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class GamicoPurchaseButton extends StatelessWidget {
  final ProductDetails productDetails;

  const GamicoPurchaseButton({super.key, required this.productDetails});

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (PurchasesCubit purchasesCubit) => purchasesCubit.state.status,
    );

    final title = GamicoGlobalService.simplifyProductName(productDetails.title);

    return GamicoDisabler(
      disabled: status == PurchasesStatus.failure,
      child: GamicoIconTextButton(
        loading: status == PurchasesStatus.loading,
        iconWidget: const CoinsWidget(size: 50, color: Colors.white),
        text:
            "$title\n(${productDetails.rawPrice.toStringAsFixed(2)} ${productDetails.currencyCode})",
        onPressed: () {
          context.read<PurchasesCubit>().purchase(productDetails);
        },
      ),
    );
  }
}
