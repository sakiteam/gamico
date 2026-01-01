import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/coins_popup.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/services/animation.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> globalNavigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? currentPopupContext;

  static List<BuildContext> popupsContexts = [];

  static Future<void> push(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return page;
        },
      ),
    );
  }

  static Future<void> replace(BuildContext context, Widget page) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return page;
        },
      ),
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    popupsContexts.remove(context);

    if (context.mounted) {
      Navigator.pop(context, result);
    }
  }

  static Future<void> maybePop(BuildContext context) async {
    await Navigator.maybePop(context);
  }

  static Future<T?> pushPageWithAnimation<T>(
    BuildContext context,
    Widget page,
  ) async {
    await Future.delayed(AnimationService.animationDuration);

    return await Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  static Future<void> replacePageWithAnimation(
    BuildContext context,
    Widget page,
  ) async {
    // await Future.delayed(AnimationService.animationDuration);

    await Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  static void closePopups() {
    final popupsContextsCopy = [...popupsContexts];

    for (final context in popupsContextsCopy) {
      NavigationService.pop(context);
    }
  }

  static Future<void> showPopup({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool draggable = true,
    bool dismissible = true,
  }) async {
    final musicCubit = context.read<GamicoMusicCubit>();

    closePopups();

    popupsContexts.add(context);

    currentPopupContext = context;

    musicCubit.playPopupOpenBruitage();

    await showModalBottomSheet(
      context: context,
      isDismissible: dismissible,
      enableDrag: draggable,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: builder,
      constraints: const BoxConstraints(),
    );

    if (currentPopupContext == context) {
      musicCubit.playPopupCloseBruitage();
    }

    popupsContexts.remove(context);

    // removeContextFromStack(currentPopupContext!);
  }

  // static void removeContextFromStack(BuildContext context) {
  //   if (GlobalService.currentPopupContext == context) {
  //     GlobalService.currentPopupContext = null;
  //     context.read<MusicCubit>().playPopupCloseBruitage();
  //   }
  // }

  static Future<void> showCowriesPopup(
    BuildContext context,
    int? minimumRequiredCowries,
  ) async {
    await NavigationService.showPopup(
      context: context,
      builder: (_) =>
          CoinsPopup(minimumRequiredCowries: minimumRequiredCowries),
    );
  }
}
