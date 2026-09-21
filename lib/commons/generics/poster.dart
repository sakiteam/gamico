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
  final Color? currentTitleColor;
  final Color? currentIconColor;
  final Color? currentDescriptionColor;
  final bool loading;
  final bool expandIcon;
  final bool expandContent;
  final bool expandDescription;
  final double animationTarget;

  static const double titleFontSize = 24.75;
  static const double descriptionFontSize = 19.125;
  static const double descriptionHeight = 57.375;
  static const double iconSize = 67.5;
  static const double sectionHeight = 112.5;
  static const double spacing = 18;
  static const double topSpacing = 16;
  static const int descriptionMaxLines = 3;
  static const double slideBegin = 0.125;
  static Color titleColor = Colors.white;
  static Color iconColor = Colors.brown.shade700;
  static Color descriptionColor = Colors.brown.shade700;
  static EdgeInsets defaultPadding = EdgeInsets.symmetric(
    horizontal: LayoutService.optionButtonMargin,
  );
  final EdgeInsets? padding;
  final EdgeInsets? iconPadding;
  final EdgeInsets? titlePadding;
  final EdgeInsets? descriptionPadding;
  final EdgeInsets? contentPadding;
  final Color? loaderColor;

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
    this.expandDescription = false,
    this.animationTarget = 1,
    this.padding,
    this.iconPadding,
    this.titlePadding,
    this.descriptionPadding,
    this.contentPadding,
    this.loaderColor,
    this.currentTitleColor,
    this.currentIconColor,
    this.currentDescriptionColor,
  });

  Widget _animated(Widget child, int order) {
    return child
        .animate(target: animationTarget)
        .fadeIn(
          delay: AnimationService.animationDurationQuarter * order,
          duration: AnimationService.animationDurationQuarter,
        )
        .slideY(begin: slideBegin);
  }

  @override
  Widget build(BuildContext context) {
    final finalDefaultPadding = padding ?? defaultPadding;

    final defaultIconWidget =
        iconWidget ??
        (icon == null
            ? null
            : Icon(icon, size: iconSize, color: currentIconColor ?? iconColor));

    final finalIconWidget = defaultIconWidget != null
        ? expandIcon
              ? Expanded(child: defaultIconWidget)
              : Container(
                  height: sectionHeight,
                  alignment: Alignment.center,
                  child: defaultIconWidget,
                )
        : null;

    final finalDescriptionWidget =
        (descriptionWidget ??
        (description != null
            ? SizedBox(
                height: descriptionHeight,
                child: AutoSizeText(
                  description!,
                  maxLines: descriptionMaxLines,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: currentDescriptionColor ?? descriptionColor,
                  ),
                ),
              )
            : null));

    final finalTitleWidget =
        titleWidget ??
        (title != null
            ? GamicoPosterTitle(title, color: currentTitleColor)
            : null);

    final Widget? finalContentWidget;

    if (loading) {
      final loader = Center(child: GamicoLoader(color: loaderColor));

      finalContentWidget = expandContent
          ? Expanded(child: loader)
          : SizedBox(height: sectionHeight, child: loader);
    } else {
      final finalContentPadding = contentPadding ?? finalDefaultPadding;

      finalContentWidget = content == null
          ? null
          : expandContent
          ? Expanded(
              child: Padding(padding: finalContentPadding, child: content!),
            )
          : SizedBox(
              height: sectionHeight,
              child: Center(
                child: Padding(padding: finalContentPadding, child: content!),
              ),
            );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (finalIconWidget != null) const SizedBox(height: topSpacing),
        if (finalIconWidget != null)
          Padding(
            padding: iconPadding ?? finalDefaultPadding,
            child: _animated(finalIconWidget, 0),
          ),
        if (finalIconWidget != null && finalTitleWidget != null)
          const SizedBox(height: spacing),
        if (finalTitleWidget != null)
          Padding(
            padding: titlePadding ?? finalDefaultPadding,
            child: _animated(finalTitleWidget, 1),
          ),
        if (finalTitleWidget != null && finalDescriptionWidget != null)
          const SizedBox(height: spacing),
        if (finalDescriptionWidget != null)
          Expanded(
            flex: expandDescription ? 1 : 0,
            child: Padding(
              padding: descriptionPadding ?? finalDefaultPadding,
              child: _animated(finalDescriptionWidget, 2),
            ),
          ),
        if (finalDescriptionWidget != null &&
            finalContentWidget != null &&
            !expandContent)
          const SizedBox(height: spacing),
        if (finalContentWidget != null) _animated(finalContentWidget, 3),
      ],
    );
  }
}

class GamicoPosterTitle extends StatelessWidget {
  const GamicoPosterTitle(this.title, {super.key, this.color});

  final String? title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GamicoOutlinedText(
      title ?? "",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: GamicoPoster.titleFontSize,
        fontWeight: FontWeight.bold,
        color: color ?? GamicoPoster.titleColor,
      ),
    );
  }
}
