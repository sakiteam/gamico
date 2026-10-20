import 'package:firebase_database/firebase_database.dart';

enum InvitationStatus { pending, accepted, rejected }

class InvitationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? gameSettings;

  const InvitationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.gameSettings,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: InvitationStatus.values.byName(
        json['status'].toLowerCase() as String,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      gameSettings: json['settings'] != null
          ? Map<String, dynamic>.from(json['settings'] as Map)
          : null,
    );
  }

  factory InvitationModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return InvitationModel.fromJson(Map<String, dynamic>.from(data));
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status.name.toUpperCase(),
      // UTC with its `Z`: the receiver ages the invitation against its own
      // clock, and a zone-less stamp reads as local time there — an
      // invitation sent from west of UTC looked hours old in Abidjan.
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
      'settings': gameSettings,
    };
  }

  InvitationModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? gameSettings,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gameSettings: gameSettings ?? this.gameSettings,
    );
  }
}
