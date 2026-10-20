import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/services/timestamp.dart';

class GamicoGenericProvider {
  final ref = FirebaseDatabase.instance.ref();

  /// [stamp] overrides the `created_at`/`updated_at` value, for nodes whose
  /// creation time other devices read back (see [TimestampService.sharedNow]).
  Future<String> createData(
    String col,
    Map<String, dynamic> doc, {
    String? stamp,
  }) async {
    try {
      final pushRef = ref.child(col).push();
      final now = stamp ?? DateTime.now().toString();

      doc = Map<String, dynamic>.from(doc);
      doc.remove("id");
      doc["created_at"] = now;
      doc["updated_at"] = now;

      final jsonDoc = jsonDecode(
        jsonEncode(
          doc,
          toEncodable: (dynamic item) {
            return item?.toString();
          },
        ),
      );

      await pushRef.set(jsonDoc);

      return pushRef.key ?? "";
    } catch (e) {
      debugPrint("Error creating data $col: $e");
      return "";
    }
  }

  Future<Map<String, dynamic>> readData(String col, String id) async {
    try {
      final snapshot = await ref.child("$col/$id").get();
      final value = snapshot.value;
      if (value == null) {
        return <String, dynamic>{"id": snapshot.key};
      }

      final data = Map<String, dynamic>.from(jsonDecode(jsonEncode(value)));
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
      final jsonDoc = jsonDecode(
        jsonEncode(
          doc,
          toEncodable: (dynamic item) {
            return item?.toString();
          },
        ),
      );
      await ref.child("$col/$id").update(jsonDoc);
    } catch (e) {
      debugPrint("Error updating data $col/$id: $e");
    }
  }

  /// Atomically rewrites a single node through an RTDB transaction.
  ///
  /// [update] receives the value currently on the server and returns the value
  /// to store, or null to abort the transaction and leave the node untouched.
  /// Unlike [updateData] this is immune to the read-modify-write race that a
  /// stale local copy causes: the server value is the one being edited, never
  /// whatever this device happens to hold.
  /// Resolves to true once the server has settled the transaction — whether it
  /// committed or aborted, both mean the server value is now known-good. It
  /// does NOT resolve while offline: RTDB holds the transaction until it
  /// reconnects, which is exactly the signal a caller queuing an unconfirmed
  /// gain needs. Resolves to false when the write errored outright.
  Future<bool> transactData(
    String path,
    Object? Function(Object? current) update,
  ) async {
    try {
      await ref.child(path).runTransaction((current) {
        final next = update(current);
        if (next == null) return Transaction.abort();
        return Transaction.success(next);
      });
      return true;
    } catch (e) {
      debugPrint("Error transacting data $path: $e");
      return false;
    }
  }

  Future<void> deleteData(String col, String id) async {
    try {
      await ref.child("$col/$id").remove();
    } catch (e) {
      debugPrint("Error deleting data $col/$id: $e");
    }
  }
}
