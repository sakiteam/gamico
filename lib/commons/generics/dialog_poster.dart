import 'package:flutter/material.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/languages/languages.dart';

class GamicoDialogPoster extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? description;
  final Widget? content;

  final Widget? iconWidget;
  final Widget? descriptionWidget;

  final bool expandIcon;
  final bool expandContent;

  final String? acceptationText;
  final IconData? acceptationIcon;
  final Function? onAccepted;
  final bool acceptationButtonEnabled;

  final String? rejectionText;
  final IconData? rejectionIcon;
  final Function? onRejected;
  final bool rejectionButtonEnabled;

  final bool automaticClose;
  final bool simple;

  final bool loading;

  final Widget? acceptationIconWidget;
  final Widget? rejectionIconWidget;

  const GamicoDialogPoster({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.content,
    this.iconWidget,
    this.descriptionWidget,
    this.expandIcon = false,
    this.expandContent = true,
    //
    this.simple = false,
    this.acceptationText,
    this.acceptationIcon,
    this.onAccepted,
    this.rejectionText,
    this.rejectionIcon,
    this.onRejected,
    this.automaticClose = true,
    this.loading = false,
    //
    this.acceptationIconWidget,
    this.rejectionIconWidget,
    //
    this.acceptationButtonEnabled = true,
    this.rejectionButtonEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoPoster(
      content:
          content ??
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!simple)
                GamicoIconTextButton(
                  onPressed:
                      !rejectionButtonEnabled
                          ? null
                          : () {
                            if (automaticClose) {
                              NavigationService.pop(context);
                            }

                            onRejected?.call();
                          },
                  iconData: rejectionIcon ?? Icons.close,
                  text: rejectionText ?? l.globalCancel,
                  iconWidget: rejectionIconWidget,
                ),
              if (!simple)
                GamicoIconTextButton(
                  color: ColorService.accentColor,
                  onPressed:
                      !acceptationButtonEnabled
                          ? null
                          : () {
                            if (automaticClose) {
                              NavigationService.pop(context);
                            }

                            onAccepted?.call();
                          },
                  text: acceptationText ?? l.globalValidate,
                  iconData: acceptationIcon ?? Icons.check,
                  iconWidget: acceptationIconWidget,
                ),
              if (simple)
                GamicoIconTextButton(
                  color: ColorService.accentColor,
                  onPressed: () {
                    if (automaticClose) {
                      NavigationService.pop(context);
                    }

                    onAccepted?.call();
                  },
                  text: acceptationText ?? l.globalOK,
                  iconData: acceptationIcon ?? Icons.check,
                  iconWidget: acceptationIconWidget,
                ),
            ],
          ),
      loading: loading,
      description: description,
      descriptionWidget: descriptionWidget,
      expandContent: expandContent,
      expandIcon: expandIcon,
      icon: icon,
      iconWidget: iconWidget,
      title: title,
    );
  }
}
