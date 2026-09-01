import 'package:flutter/material.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/commons/models/adventure_utility.dart';

@immutable
class PagesSettings {
  final Widget Function(BuildContext context) loadingPage;
  final Widget Function(BuildContext context) homePage;
  final Widget Function(BuildContext context, GameUtility gameUtility) gamePage;
  final Widget Function(
    BuildContext context,
    RemoteUtility remoteUtility,
    AdventureUtility adventureUtility,
    int? level,
  ) remotePage;

  const PagesSettings({
    required this.homePage,
    required this.gamePage,
    required this.remotePage,
    required this.loadingPage,
  });
}

final defaultPagesSettings = PagesSettings(
  loadingPage: (context) => const Material(),
  homePage: (context) => const Material(),
  gamePage: (context, utility) => const Material(),
  remotePage: (context, remoteUtility, adventureUtility, level) =>
      const Material(),
);
