import 'package:flutter/material.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';

@immutable
class PagesSettings {
  final Widget Function(BuildContext context) loadingPage;
  final Widget Function(BuildContext context) homePage;
  final Widget Function(BuildContext context, GameUtility gameUtility) gamePage;

  const PagesSettings({
    required this.loadingPage,
    required this.homePage,
    required this.gamePage,
  });
}

// final defaultPagesSettings = PagesSettings(
//   loadingPage: (context) => const SizedBox(),
//   homePage: (context) => const SizedBox(),
//   gamePage: (context, utility) => const SizedBox(),
// );
