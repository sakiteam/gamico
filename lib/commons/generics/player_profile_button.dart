import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/generics/game_profile_poster.dart';
import 'package:gamico/commons/modes/adventure_mode_settings.dart';

enum GamicoPlayerProfileButtonType { local, other }

class GamicoPlayerProfileButton extends StatelessWidget {
  final double? iconSize;
  final GamicoPlayerProfileButtonType type;
  final Widget Function(
    BuildContext context,
    Widget child,
    void Function() onPressed,
  ) builder;

  const GamicoPlayerProfileButton({
    super.key,
    this.iconSize,
    required this.type,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final gameMode =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.gameMode);

    final bool ai;
    final GamicoUserModel user;
    final String? description;

    if (type == GamicoPlayerProfileButtonType.local) {
      user = gameMode.localPlayerProfile(context);
      description = gameMode.localPlayerDescription(context);

      ai = false;
    } else {
      user = gameMode.otherPlayerProfile(context);
      description = gameMode.otherPlayerDescription(context);
      ai = gameMode is AdventureModeSettings;
    }

    return builder(
      context,
      user.photo == null
          ? Icon(
              ai ? Icons.android : Icons.person,
              size: iconSize ?? 16,
              color: Colors.white,
            )
          : CachedNetworkImage(
              imageUrl: user.photo!,
              fit: BoxFit.fill,
              errorWidget: (_, _, _) => Icon(
                ai ? Icons.android : Icons.person,
                size: iconSize ?? 16,
                color: Colors.white,
              ),
            ),
      () {
        NavigationService.showPopup(
          context: context,
          builder: (_) {
            return GamicoGameProfilePoster(
              user: user,
              description: description,
              ai: ai,
            );
          },
        );
      },
    );
  }
}
