import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/generics/popup_button.dart';
import 'package:gamico/languages/languages.dart';

class GamicoAdButtonState {
  final String label;
  final String? adText;
  final void Function()? onPressed;
  final Color? color;
  final bool loading;
  final bool failure;

  const GamicoAdButtonState({
    required this.label,
    required this.adText,
    required this.onPressed,
    required this.color,
    required this.loading,
    required this.failure,
  });
}

class GamicoAdButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;
  final Color? color;

  static Widget Function(GamicoPopupButton button, bool failure)? builder;

  const GamicoAdButton({super.key, this.onPressed, this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocBuilder<AdmobCubit, AdmobState>(
      builder: (context, state) {
        final failure = state.rewardedAdStatus == AdmobRewardedAdStatus.failure;

        final gamicoPopupButton = GamicoPopupButton(
          iconText: failure
              ? null
              : l.globalAd.length > 3
              ? "AD"
              : l.globalAd,
          foregroundColor: failure ? Colors.brown : color,
          icon: failure ? Icons.refresh : Icons.movie,
          text: failure
              ? l.watchAdButtonRefreshAd
              : (text ?? l.watchAdButtonWatchAd),
          loading: state.rewardedAdStatus == AdmobRewardedAdStatus.loading,
          onPressed: failure
              ? () {
                  context.read<AdmobCubit>().loadRewardedAd();
                }
              : onPressed,
        );

        return builder?.call(gamicoPopupButton, failure) ?? gamicoPopupButton;
      },
    );
  }
}
