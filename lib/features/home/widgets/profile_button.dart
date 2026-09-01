import 'package:flutter/material.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/generics/authentication_popup.dart';
import 'package:gamico/features/home/widgets/home_profile_popup.dart';

class GamicoProfileButton extends StatelessWidget {
  final Widget Function(BuildContext context, void Function() onPressed)
      builder;

  const GamicoProfileButton({
    super.key,
    required this.builder,
  });

  void _showProfilePopup(BuildContext context) {
    NavigationService.showPopup(
      context: context,
      builder: (_) {
        return const HomeProfilePopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, () {
      if (UserService.authenticated) {
        _showProfilePopup(context);
      } else {
        NavigationService.showPopup(
          context: context,
          dismissible: false,
          draggable: false,
          builder: (_) {
            return GamicoAuthenticationPopup(
              onSuccess: () => _showProfilePopup(context),
            );
          },
        );
      }
    });
  }
}
