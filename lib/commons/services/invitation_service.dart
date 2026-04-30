import 'package:firebase_database/firebase_database.dart';

class InvitationService {
  static Future<String?> getUserToken(String userId) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(userId)
          .child('token')
          .get();

      if (snapshot.exists) {
        return snapshot.value as String?;
      }
    } catch (e) {
      // Handle error or return null
    }
    return null;
  }
}
