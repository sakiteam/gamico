import 'package:flutter/material.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/providers/gamico_users_provider.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';
import 'package:gamico/commons/utilities/couple/couple_utility.dart';

@immutable
class UserSettings {
  final GamicoUsersRepository usersRepository;
  final dynamic Function(String firebaseId, String socialId) createNewUser;
  final dynamic Function(dynamic, dynamic) userCreateFakeOpponent;
  final List<GamicoCoupleUtility<String>> Function(
    BuildContext context,
    dynamic user,
  ) userProfile;

  /// Whether the user cubit writes `online`/`updated_at` on `users/{uid}`
  /// itself.
  ///
  /// Set it false in an app that already runs its own presence service, or the
  /// two write the same flag on every reconnection and lifecycle change — two
  /// writes, two `users/{uid}` echoes back to this very device, and two
  /// `syncProfileOnline` invocations, for one state change. Ludiko owns
  /// presence in `UserPresenceService`, which additionally tracks
  /// `current_game`/`current_game_id`, so this side stands down there.
  ///
  /// Defaults to true so an app with no presence service of its own keeps
  /// getting it from here.
  final bool managePresence;

  const UserSettings({
    required this.usersRepository,
    required this.createNewUser,
    required this.userCreateFakeOpponent,
    required this.userProfile,
    this.managePresence = true,
  });
}

final defaultUserSettings = UserSettings(
  createNewUser: (firebaseId, socialId) => const GamicoUserModel(),
  userCreateFakeOpponent: (currentUser, finalOpponent) =>
      const GamicoUserModel(),
  userProfile: (context, user) => [],
  usersRepository: GamicoUsersRepository(
    fromJson: GamicoUserModel.fromJson,
    toJson: (user) => user.toJson(),
    usersProvider: GamicoUsersProvider(),
  ),
);
