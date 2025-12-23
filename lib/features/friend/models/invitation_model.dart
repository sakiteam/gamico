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
      gameSettings: json['settings'] as Map<String, dynamic>?,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
