import 'package:flutter/material.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/languages/languages.dart';

class GamicoDialogPoster extends StatefulWidget {
  final IconData? icon;
  final String? title;

  /// Replaces [title] when the title needs more than a line of text.
  final Widget? titleWidget;
  final String? description;
  final Widget? content;

  final Widget? iconWidget;
  final Widget? descriptionWidget;

  final bool expandIcon;
  final bool expandContent;
  final bool expandDescription;

  final String? acceptationText;
  final IconData? acceptationIcon;
  final Function? onAccepted;
  final bool acceptationButtonEnabled;
  final Color? acceptationColor;

  final String? rejectionText;
  final IconData? rejectionIcon;
  final Function? onRejected;
  final bool rejectionButtonEnabled;
  final Color? rejectionColor;

  final bool automaticClose;
  final bool simple;

  final bool loading;

  final Widget? acceptationIconWidget;
  final Widget? rejectionIconWidget;

  final Color? titleColor;
  final Color? descriptionColor;
  final Color? iconColor;

  const GamicoDialogPoster({
    super.key,
    this.icon,
    this.title,
    this.titleWidget,
    this.description,
    this.content,
    this.iconWidget,
    this.descriptionWidget,
    this.expandIcon = false,
    this.expandContent = true,
    this.expandDescription = false,
    //
    this.simple = false,
    this.acceptationText,
    this.acceptationIcon,
    this.onAccepted,
    this.rejectionText,
    this.rejectionIcon,
    this.onRejected,
    this.rejectionColor,
    this.automaticClose = true,
    this.loading = false,
    this.acceptationColor,
    //
    this.acceptationIconWidget,
    this.rejectionIconWidget,
    //
    this.acceptationButtonEnabled = true,
    this.rejectionButtonEnabled = true,
    //
    this.titleColor,
    this.descriptionColor,
    this.iconColor,
  });

  @override
  State<GamicoDialogPoster> createState() => _GamicoDialogPosterState();
}

class _GamicoDialogPosterState extends State<GamicoDialogPoster> {
  // Set as soon as a button closes the dialog. A second tap can land while the
  // exit animation is still playing (the widget stays mounted until it ends),
  // which would fire onAccepted / onRejected twice.
  bool _dismissed = false;

  void _handlePressed(Function? callback) {
    if (!widget.automaticClose) {
      callback?.call();
      return;
    }

    if (_dismissed) return;
    _dismissed = true;

    NavigationService.pop(context);
    callback?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoPoster(
      currentIconColor: widget.iconColor,
      currentTitleColor: widget.titleColor,
      currentDescriptionColor: widget.descriptionColor,
      content:
          widget.content ??
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!widget.simple)
                GamicoIconTextButton(
                  color: widget.rejectionColor,
                  onPressed: !widget.rejectionButtonEnabled
                      ? null
                      : () => _handlePressed(widget.onRejected),
                  iconData: widget.rejectionIcon ?? Icons.close,
                  text: widget.rejectionText ?? l.globalCancel,
                  iconWidget: widget.rejectionIconWidget,
                ),

              if (widget.simple)
                GamicoIconTextButton(
                  color: widget.acceptationColor ?? ColorService.accentColor,
                  onPressed: () => _handlePressed(widget.onAccepted),
                  text: widget.acceptationText ?? l.globalOK,
                  iconData: widget.acceptationIcon ?? Icons.check,
                  iconWidget: widget.acceptationIconWidget,
                )
              else
                GamicoIconTextButton(
                  color: widget.acceptationColor ?? ColorService.accentColor,
                  onPressed: !widget.acceptationButtonEnabled
                      ? null
                      : () => _handlePressed(widget.onAccepted),
                  text: widget.acceptationText ?? l.globalValidate,
                  iconData: widget.acceptationIcon ?? Icons.check,
                  iconWidget: widget.acceptationIconWidget,
                ),
            ],
          ),
      loading: widget.loading,
      description: widget.description,
      descriptionWidget: widget.descriptionWidget,
      expandContent: widget.expandContent,
      expandDescription: widget.expandDescription,
      expandIcon: widget.expandIcon,
      icon: widget.icon,
      iconWidget: widget.iconWidget,
      title: widget.title,
      titleWidget: widget.titleWidget,
    );
  }
}
