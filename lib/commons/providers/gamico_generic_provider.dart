import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class GamicoGenericProvider {
  final ref = FirebaseDatabase.instance.ref();

  Future<String> createData(
    String col,
    Map<String, dynamic> doc,
  ) async {
    try {
      final pushRef = ref.child(col).push();
      final now = DateTime.now().toString();

      doc = Map<String, dynamic>.from(doc);
      doc.remove("id");
      doc["created_at"] = now;
      doc["updated_at"] = now;

      final jsonDoc = jsonDecode(jsonEncode(doc, toEncodable: (dynamic item) {
        return item?.toString();
      }));

      await pushRef.set(jsonDoc);

      return pushRef.key ?? "";
    } catch (e) {
      debugPrint("Error creating data $col: $e");
      return "";
    }
  }

  Future<Map<String, dynamic>> readData(
    String col,
    String id,
  ) async {
    try {
      final snapshot = await ref.child("$col/$id").get();
      final value = snapshot.value;
      if (value == null) {
        return <String, dynamic>{"id": snapshot.key};
      }

      final data =
          Map<String, dynamic>.from(jsonDecode(jsonEncode(value)));
      data["id"] = snapshot.key;

      return data;
    } catch (e) {
      debugPrint("Error reading data $col/$id: $e");
      return <String, dynamic>{"id": id};
    }
  }

  Future<void> updateData(
    String col,
    String id,
    Map<String, dynamic> doc,
  ) async {
    try {
      doc = Map<String, dynamic>.from(doc);
      doc.remove("id");
      doc.remove("created_at");
      doc["updated_at"] = DateTime.now().toString();
      final jsonDoc = jsonDecode(jsonEncode(doc, toEncodable: (dynamic item) {
        return item?.toString();
      }));
      await ref.child("$col/$id").update(jsonDoc);
    } catch (e) {
      debugPrint("Error updating data $col/$id: $e");
    }
  }

  Future<void> deleteData(
    String col,
    String id,
  ) async {
    try {
      await ref.child("$col/$id").remove();
    } catch (e) {
      debugPrint("Error deleting data $col/$id: $e");
    }
  }
}
