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

  const UserSettings({
    required this.usersRepository,
    required this.createNewUser,
    required this.userCreateFakeOpponent,
    required this.userProfile,
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
