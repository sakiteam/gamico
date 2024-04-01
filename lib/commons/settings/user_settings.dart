import 'package:gamico/commons/repositories/gamico_users_repository.dart';

class UserSettings {
  final GamicoUsersRepository usersRepository;
  final dynamic Function(String firebaseId, String socialId) createNewUser;
  final dynamic Function(dynamic, dynamic) userCreateFakeOpponent;

  const UserSettings({
    required this.usersRepository,
    required this.createNewUser,
    required this.userCreateFakeOpponent,
  });
}
