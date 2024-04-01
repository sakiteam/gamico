import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/generics/loader.dart';
import 'package:gamico/commons/generics/outlined_text.dart';
import 'package:gamico/commons/services/layout.dart';

class GamicoPoster extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? description;
  final Widget? content;
  final Widget? titleWidget;

  final Widget? iconWidget;
  final Widget? descriptionWidget;

  final bool loading;

  final bool expandIcon;
  final bool expandContent;

  final double animationTarget;
  final EdgeInsets? padding;

  static const double titleFontSize = 22 * 450 / 400;
  static const double descriptionFontSize = 17 * 450 / 400;
  static Color iconColor = Colors.brown.shade700;
  static Color descriptionColor = Colors.brown.shade700;

  const GamicoPoster({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.content,
    this.iconWidget,
    this.titleWidget,
    this.descriptionWidget,
    this.loading = false,
    this.expandIcon = false,
    this.expandContent = false,
    this.animationTarget = 1,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconWidget = iconWidget ??
        (icon == null
            ? null
            : Icon(
                icon,
                size: 60 * 450 / 400,
                color: iconColor,
              ));

    final finalIconWidget = defaultIconWidget != null
        ? expandIcon
            ? Expanded(
                child: defaultIconWidget,
              )
            : Container(
                height: 100 * 450 / 400,
                alignment: Alignment.center,
                child: defaultIconWidget,
              )
        : null;

    final finalDescriptionWidget = descriptionWidget ??
        (description != null
            ? SizedBox(
                // color: Colors.red,
                height: 51 * 450 / 400,
                child: AutoSizeText(
                  description!,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: descriptionColor,
                  ),
                ),
              )
            : null);

    final finalTitleWidget =
        titleWidget ?? (title != null ? GamicoPosterTitle(title) : null);

    final Widget? finalContentWidget;

    if (loading) {
      finalContentWidget = expandContent
          ? const Expanded(
              child: Center(child: GamicoLoader()),
            )
          : const SizedBox(
              height: 100 * 450 / 400,
              child: Center(
                child: GamicoLoader(),
              ),
            );
    } else {
      finalContentWidget = content == null
          ? null
          : expandContent
              ? Expanded(
                  child: content!,
                )
              : SizedBox(
                  height: 100 * 450 / 400,
                  child: Center(
                    child: content!,
                  ),
                );
    }

    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(horizontal: LayoutService.optionButtonMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (finalIconWidget != null) const SizedBox(height: 16),
          if (finalIconWidget != null)
            finalIconWidget
                .animate(target: animationTarget)
                .fadeIn(
                    delay: AnimationService.animationDurationQuarter * 0,
                    duration: AnimationService.animationDurationQuarter)
                .slideY(begin: 0.125),
          if (finalIconWidget != null && finalTitleWidget != null)
            const SizedBox(height: 16 * 450 / 400),
          if (finalTitleWidget != null)
            finalTitleWidget
                .animate(target: animationTarget)
                .fadeIn(
                    delay: AnimationService.animationDurationQuarter * 1,
                    duration: AnimationService.animationDurationQuarter)
                .slideY(begin: 0.125),
          if (finalTitleWidget != null && finalDescriptionWidget != null)
            const SizedBox(height: 16 * 450 / 400),
          if (finalDescriptionWidget != null)
            finalDescriptionWidget
                .animate(target: animationTarget)
                .fadeIn(
                    delay: AnimationService.animationDurationQuarter * 2,
                    duration: AnimationService.animationDurationQuarter)
                .slideY(begin: 0.125),
          if (finalDescriptionWidget != null &&
              finalContentWidget != null &&
              !expandContent)
            const SizedBox(height: 16 * 450 / 400),
          if (finalContentWidget != null)
            finalContentWidget
                .animate(target: animationTarget)
                .fadeIn(
                    delay: AnimationService.animationDurationQuarter * 3,
                    duration: AnimationService.animationDurationQuarter)
                .slideY(begin: 0.125),
        ],
      ),
    );
  }
}

class GamicoPosterTitle extends StatelessWidget {
  const GamicoPosterTitle(
    this.title, {
    super.key,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    return GamicoOutlinedText(
      title ?? "",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: GamicoPoster.titleFontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
