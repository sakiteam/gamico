import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/generics/info_line.dart';
import 'package:gamico/commons/generics/user_photo.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGameProfilePoster extends StatelessWidget {
  final GamicoUserModel user;
  final String? description;
  final bool? ai;

  const GamicoGameProfilePoster({
    super.key,
    required this.user,
    this.description,
    this.ai,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoPopup(
      child: GamicoPoster(
        iconWidget: GamicoUserPhoto(
          user.photo,
          icon: ai == true ? Icons.android : null,
        ),
        title: user.name?.toUpperCase() ?? l.newPlayer,
        description: description,
        descriptionWidget: description != null
            ? null
            : Column(
                children: Gamico.instance.userSettings
                    .userProfile(context, user)
                    .map<Widget>((e) => GamicoInfoLine(coupleUtility: e))
                    .toList(),
              ),
        expandContent: true,
        content: Center(
          child: GamicoIconTextButton(
            text: l.gameProfilePosterClose,
            color: ColorService.accentColor,
            iconData: Icons.close,
            onPressed: () {
              NavigationService.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
