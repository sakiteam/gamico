import 'package:gamico/commons/providers/gamico_generic_provider.dart';

class GamicoUsersProvider extends GamicoGenericProvider {
  Future<String> createUser(Map<String, dynamic> doc) {
    return createData("users", doc);
  }

  Future<Map<String, dynamic>> readUser(String id) {
    return readData("users", id);
  }

  Future<void> updateUser(String id, Map<String, dynamic> doc) {
    return updateData("users", id, doc);
  }

  Future<void> deleteUser(String id) {
    return deleteData("users", id);
  }
}
