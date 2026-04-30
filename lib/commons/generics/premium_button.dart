import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/generics/popup_button.dart';
// import 'package:gamico/languages/languages.dart';

class GamicoPremiumButton extends StatelessWidget {
  final Widget Function(BuildContext context, bool loading, void Function() buy)
  builder;

  const GamicoPremiumButton({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final loading = context.select((PurchasesCubit c) {
      return [
        PurchasesStatus.loading,
        PurchasesStatus.transactionLoading,
      ].contains(c.state.status);
    });

    return builder(context, loading, () {
      context.read<PurchasesCubit>().buyPremium();
    });
  }
}

class GamicoPremiumRestoreButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;
  final Color? color;

  static Widget Function(GamicoPopupButton button)? builder;

  const GamicoPremiumRestoreButton({
    super.key,
    this.onPressed,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // final l = GamicoLanguages.of(context);

    return BlocBuilder<PurchasesCubit, PurchasesState>(
      builder: (context, state) {
        final cubit = context.read<PurchasesCubit>();
        final loading =
            state.status == PurchasesStatus.loading ||
            state.status == PurchasesStatus.transactionLoading;

        final gamicoPopupButton = GamicoPopupButton(
          icon: Icons.restore,
          text: text,
          foregroundColor: color,
          loading: loading,
          onPressed: loading
              ? null
              : () {
                  cubit.restorePremiumPurchases();
                  onPressed?.call();
                },
        );

        return builder?.call(gamicoPopupButton) ?? gamicoPopupButton;
      },
    );
  }
}
