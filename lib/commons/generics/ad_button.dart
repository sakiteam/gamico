import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/generics/popup_button.dart';
import 'package:gamico/languages/languages.dart';

class GamicoAdButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;
  final Color? color;

  const GamicoAdButton({
    super.key,
    this.onPressed,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocBuilder<AdmobCubit, AdmobState>(
      builder: (context, state) {
        if (state.rewardedAdStatus == AdmobRewardedAdStatus.failure) {
          return GamicoPopupButton(
            foregroundColor: Colors.brown,
            icon: Icons.refresh,
            text: l.watchAdButtonRefreshAd,
            // loading: state.rewardedAdStatus == AdmobRewardedAdStatus.loading,
            onPressed: () {
              context.read<AdmobCubit>().loadRewardedAd();
            },
          );
        }

        final adText = l.globalAd;

        return GamicoPopupButton(
          iconText: adText.length > 3 ? "AD" : adText,
          foregroundColor: color,
          icon: Icons.movie,
          text: text ?? l.watchAdButtonWatchAd,
          loading: state.rewardedAdStatus == AdmobRewardedAdStatus.loading,
          onPressed: onPressed,
        );
      },
    );
  }
}
