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
    FocusManager.instance.primaryFocus?.unfocus();
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
    FocusManager.instance.primaryFocus?.unfocus();
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
    FocusManager.instance.primaryFocus?.unfocus();
    popupsContexts.remove(context);

    if (!context.mounted) return;

    final nav = Navigator.maybeOf(context);
    // canPop() == false means the navigator has no route left to pop. That
    // happens on a second tap fired while the previous pop's exit animation is
    // still playing: the context is still mounted and the Navigator is still
    // findable, so neither guard above catches it, and pop() would throw
    // "Bad state: No element" from _history.lastWhere().
    if (nav == null || !nav.canPop()) return;

    nav.pop(result);
  }

  static Future<void> maybePop(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Navigator.maybePop(context);
  }

  static Future<T?> pushPageWithAnimation<T>(
    BuildContext context,
    Widget page,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    // Resolve the navigator before the delay: the caller's context may be
    // deactivated while the exit animation plays (e.g. its subtree is
    // rebuilt), which would make Navigator.of(context) throw.
    final navigator = Navigator.of(context);

    await Future.delayed(AnimationService.animationDuration);

    if (!navigator.mounted) return null;

    return await navigator.push<T>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  static Future<void> replacePageWithAnimation(
    BuildContext context,
    Widget page,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final navigator = Navigator.of(context);

    // Capture the caller's own route now. A popup (e.g. the game-over popup
    // whose "Rejouer" button triggers this) is usually dismissed just before
    // getting here, but its exit animation runs on the same duration as the
    // delay below — so after the delay it may still be the topmost route.
    // pushReplacement would then replace the *popup* instead of this page,
    // leaving the old page orphaned in the back stack (each replay stacking a
    // dead game screen the player has to walk back through). Replacing the
    // captured route explicitly makes this deterministic regardless of the
    // popup's animation state.
    final previousRoute = ModalRoute.of(context);

    await Future.delayed(AnimationService.animationDuration);

    if (!navigator.mounted) return;

    if (previousRoute != null && !previousRoute.isActive) {
      return;
    }

    final route = PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );

    if (previousRoute == null) {
      await navigator.pushReplacement(route);
      return;
    }

    final result = navigator.push(route);
    if (previousRoute.isActive) {
      try {
        navigator.removeRoute(previousRoute);
      } catch (_) {}
    }
    await result;
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
    // False skips the slide-up entrance, e.g. when a dialog reopens right
    // where the player left it (returning from a cancelled matchmaking
    // search) and shouldn't visibly "pop in" again.
    bool animate = true,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!context.mounted) return;

    GamicoMusicCubit? musicCubit;
    try {
      musicCubit = context.read<GamicoMusicCubit>();
    } catch (_) {}

    closePopups();

    popupsContexts.add(context);

    currentPopupContext = context;

    if (animate) musicCubit?.playPopupOpenBruitage();

    AnimationController? instantController;
    if (!animate) {
      instantController = AnimationController(
        vsync: Navigator.of(context),
        duration: Duration.zero,
      )..value = 1.0;
    }

    await showModalBottomSheet(
      context: context,
      isDismissible: dismissible,
      enableDrag: draggable,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: builder,
      constraints: const BoxConstraints(),
      transitionAnimationController: instantController,
    );

    instantController?.dispose();

    if (currentPopupContext == context) {
      musicCubit?.playPopupCloseBruitage();
    }

    popupsContexts.remove(context);
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
