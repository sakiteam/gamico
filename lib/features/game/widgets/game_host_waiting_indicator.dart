import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/loader.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/languages/languages.dart';

/// Shown to a WiFi-local guest at the end of a match: only the host can deal
/// the next one, so the guest waits rather than being offered a button that
/// would do nothing.
class GamicoGameHostWaitingIndicator extends StatelessWidget {
  const GamicoGameHostWaitingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const GamicoLoader(),
        const SizedBox(height: 8),
        Text(
          l.localNetworkWaitingForHost.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorService.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
