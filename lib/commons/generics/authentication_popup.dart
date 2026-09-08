import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/languages/languages.dart';

/// Modal dialog prompting the player to authenticate with Game Center / Google Play Games.
class GamicoAuthenticationPopup extends StatefulWidget {
  final void Function() onSuccess;

  const GamicoAuthenticationPopup({super.key, required this.onSuccess});

  @override
  State<GamicoAuthenticationPopup> createState() =>
      _GamicoAuthenticationPopupState();
}

class _GamicoAuthenticationPopupState extends State<GamicoAuthenticationPopup> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationCubit>().signIn();
  }

  Widget _buildErrorPoster(BuildContext context, GamicoLanguages l) {
    return GamicoDialogPoster(
      icon: Icons.error,
      title: l.authenticationPopupAuthenticationErrorTitle,
      description: l.authenticationPopupAuthenticationErrorDescription,
      acceptationIcon: Icons.refresh,
      acceptationText: l.globalRetry,
      rejectionIcon: Icons.close,
      automaticClose: false,
      onRejected: () => NavigationService.pop(context),
      onAccepted: () => context.read<AuthenticationCubit>().signIn(),
    );
  }

  Widget _buildConnectPoster(
    BuildContext context,
    GamicoLanguages l,
    AuthenticationState state,
  ) {
    final isLoading =
        state.status == AuthenticationStateStatus.loading ||
        state.status == AuthenticationStateStatus.success;

    final serviceName = Platform.isAndroid
        ? l.globalGooglePlay
        : l.globalAppleGameCenter;

    return GamicoDialogPoster(
      simple: true,
      automaticClose: false,
      icon: Icons.account_circle,
      loading: isLoading,
      onAccepted: () => context.read<AuthenticationCubit>().signIn(),
      description: l.authenticationPopupDescription(serviceName),
      title: state.status == AuthenticationStateStatus.loading
          ? l.authenticationPopupLoadingAuthentication
          : l.authenticationPopupRequiredAuthentication,
      acceptationText: l.globalConnect,
      acceptationIcon: Icons.person,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (_, state) {
        NavigationService.closePopups();
        widget.onSuccess();
      },
      listenWhen: (oldState, newState) {
        return oldState.status == AuthenticationStateStatus.loading &&
            newState.status == AuthenticationStateStatus.success;
      },
      builder: (context, state) {
        return GamicoPopup(
          dismissible: false,
          child: state.status == AuthenticationStateStatus.failure
              ? _buildErrorPoster(context, l)
              : _buildConnectPoster(context, l, state),
        );
      },
    );
  }
}
