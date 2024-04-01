import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/languages/languages.dart';

class GamicoLoadingPoster extends StatelessWidget {
  const GamicoLoadingPoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return Center(
      child: SizedBox(
        width: 360,
        child: GamicoPoster(
          icon: Icons.hourglass_empty_rounded,
          title: l.loadingTitle,
          description: l.loadingDescription,
          loading: true,
        ),
      ),
    );
  }
}
