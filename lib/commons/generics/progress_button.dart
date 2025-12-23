import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/coins_widget.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/authentication_popup.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/outlined_text.dart';
import 'package:gamico/languages/languages.dart';

class GamicoProgressButton extends StatefulWidget {
  static Color beginAnimationColor = ColorService.foregroundBlue;
  static Color endAnimationColor = ColorService.accentColor;

  final double size;
  final Widget Function(
    BuildContext context,
    int coins,
    Color? color,
    void Function() onPressed,
  )
  builder;

  static bool popupVisible = false;

  const GamicoProgressButton({
    super.key,
    required this.size,
    required this.builder,
  });

  @override
  State<GamicoProgressButton> createState() => _GamicoProgressButtonState();
}

class _GamicoProgressButtonState extends State<GamicoProgressButton>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation _blinkAnimation;
  late final AnimationController _cowriesUpdateController;

  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  int cowriesDifference = 0;
  bool _cowriesUpdateVisible = false;
  Color cowriesUpdateColor = Colors.black;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _blinkAnimation = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(
          begin: GamicoProgressButton.beginAnimationColor,
          end: GamicoProgressButton.endAnimationColor,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: GamicoProgressButton.endAnimationColor,
          end: GamicoProgressButton.beginAnimationColor,
        ),
        weight: 1,
      ),
    ]).animate(_animationController);

    // Cowries update
    _cowriesUpdateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: const Offset(1.0, 0),
    ).animate(_cowriesUpdateController);

    _fadeAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_cowriesUpdateController);

    // if (kReleaseMode) {
    _animationController.repeat();
    // }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cowriesUpdateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<GamicoUserCubit, GamicoUserState>(
          listenWhen: (previous, current) {
            return previous.cowriesUpdate != current.cowriesUpdate;
          },
          listener: (context, state) async {
            cowriesDifference = state.cowriesUpdateDifference;

            if (cowriesDifference < 0) {
              cowriesUpdateColor = ColorService.accentColor;
            } else {
              cowriesUpdateColor = Colors.blue;
            }

            // Wait for the progress option button to be visible
            await Future.delayed(AnimationService.animationDuration);

            if (mounted) {
              setState(() {
                _cowriesUpdateVisible = true;
              });
            }

            // Perform the animation
            _cowriesUpdateController.reset();
            _cowriesUpdateController.forward();

            await Future.delayed(const Duration(seconds: 1));

            if (mounted) {
              setState(() {
                _cowriesUpdateVisible = false;
              });
            }
          },
        ),
        // BlocListener<GratificationCubit, GratificationState>(
        //   listener: (context, state) {
        //     if (state.gratificationEnabled) {
        //       _animationController.repeat();
        //     } else {
        //       _animationController.stop();
        //     }
        //   },
        //   listenWhen: (previous, current) {
        //     return previous.gratificationEnabled !=
        //         current.gratificationEnabled;
        //   },
        // ),
      ],
      child: () {
        // final cowries = state.user?.cowries ?? 0;

        final cowries =
            context.select(
              (GamicoUserCubit userCubit) => userCubit.state.user?.coins,
            ) ??
            0;

        final authenticated = context.select(
          (AuthenticationCubit authenticationCubit) =>
              authenticationCubit.state.authenticated,
        );

        final gratificationEnabled = context.select(
          (GratificationCubit gratificationCubit) =>
              gratificationCubit.state.gratificationEnabled,
        );

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _blinkAnimation,
                builder: (context, child) {
                  return widget.builder(
                    context,
                    cowries,
                    (gratificationEnabled || cowries == 0) &&
                            authenticated &&
                            !GamicoProgressButton.popupVisible
                        ? _blinkAnimation.value
                        : null,
                    () async {
                      final authenticationCubit =
                          context.read<AuthenticationCubit>();

                      if (authenticationCubit.state.authenticated) {
                        setState(() {
                          GamicoProgressButton.popupVisible = true;
                        });

                        await NavigationService.showCowriesPopup(context, null);

                        setState(() {
                          GamicoProgressButton.popupVisible = false;
                        });
                      } else {
                        NavigationService.showPopup(
                          context: context,
                          dismissible: !GameService.tutorialPassed,
                          draggable: !GameService.tutorialPassed,
                          builder: (_) {
                            if (GameService.tutorialPassed) {
                              return GamicoAuthenticationPopup(
                                onSuccess: () {
                                  NavigationService.showCowriesPopup(
                                    context,
                                    null,
                                  );
                                },
                              );
                            }

                            return GamicoPopup(
                              child: GamicoDialogPoster(
                                iconWidget: CoinsWidget(
                                  color: Colors.brown.shade700,
                                  outlined: false,
                                  size: 60,
                                ),
                                title:
                                    l.progressOptionButtonNotAuthenticatedTitle,
                                description:
                                    l.progressOptionButtonNotAuthenticationDescription,
                                simple: true,
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),

              //
              if (_cowriesUpdateVisible && cowriesDifference != 0)
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      child: Container(
                        height: widget.size,
                        width: 150,
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GamicoOutlinedText(
                                cowriesDifference > 0
                                    ? "+${cowriesDifference.abs()}"
                                    : "-${cowriesDifference.abs()}",
                                strokeWidth: 1,
                                style: TextStyle(
                                  color: cowriesUpdateColor,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Transform.translate(
                                offset: const Offset(0, -3),
                                child: CoinsWidget(
                                  size: 36,
                                  color: cowriesUpdateColor,
                                  strokeWidth: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }(),
    );
  }
}
