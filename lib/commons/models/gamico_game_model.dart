import 'package:gamico/commons/services/timestamp.dart';
import 'package:meta/meta.dart';

@immutable
class GamicoGameModel {
  final String? id;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? status;

  final Map<String, GamicoGameEventModel>? events;
  final Map<String, GamicoGamePlayerModel>? players;

  /// The server's house bot at this table — `{uid, driver}`: the account its
  /// seat plays as, and the one human whose device plays it. Null at every
  /// other table.
  final Map<String, dynamic>? house;

  const GamicoGameModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.events,
    this.players,
    this.house,
  });

  /// The account the house bot plays as here, if it sits at this table.
  String? get houseUid => house?["uid"]?.toString();

  /// The device (by uid) that plays the house bot's seat.
  String? get houseDriver => house?["driver"]?.toString();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      // UTC with its `Z`: this stamp seeds every online shuffle, so all
      // devices must read it as the same instant (see
      // [TimestampService.parseShared]).
      "created_at": createdAt?.toUtc().toString(),
      "updated_at": updatedAt?.toString(),
      "status": status,
      "events": events?.map<String, Map<String, dynamic>>((key, value) {
        return MapEntry(key, value.toJson());
      }),
      "players": players?.map<String, Map<String, dynamic>>((key, value) {
        return MapEntry(key, value.toJson());
      }),
      if (house != null) "house": house,
    };
  }

  factory GamicoGameModel.fromJson(Map<String, dynamic> json) {
    return GamicoGameModel(
      id: json["id"],
      createdAt: TimestampService.parseShared(json["created_at"]?.toString()),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      status: json["status"],
      events: json["events"]?.map<String, GamicoGameEventModel>((key, value) {
        return MapEntry(key.toString(), GamicoGameEventModel.fromJson(value));
      }),
      players: json["players"]?.map<String, GamicoGamePlayerModel>((
        key,
        value,
      ) {
        return MapEntry(key.toString(), GamicoGamePlayerModel.fromJson(value));
      }),
      house: json["house"] is Map
          ? Map<String, dynamic>.from(json["house"] as Map)
          : null,
    );
  }
}

class GamicoGameEventModel {
  final String? id;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? type;
  final String? userId;
  final Map<String, dynamic>? data;

  const GamicoGameEventModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.userId,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "created_at": createdAt?.toString(),
      "updated_at": updatedAt?.toString(),
      "type": type,
      "user_id": userId,
      "data": data,
    };
  }

  factory GamicoGameEventModel.fromJson(Map<String, dynamic> json) {
    return GamicoGameEventModel(
      id: json["id"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      type: json["type"],
      userId: json["user_id"],
      data: json["data"],
    );
  }
}

class GamicoGamePlayerModel {
  final String? id;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? userId;
  final String? status;

  const GamicoGamePlayerModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "created_at": createdAt?.toString(),
      "updated_at": updatedAt?.toString(),
      "user_id": userId,
      "status": status,
    };
  }

  factory GamicoGamePlayerModel.fromJson(Map<String, dynamic> json) {
    return GamicoGamePlayerModel(
      id: json["id"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      userId: json["user_id"],
      status: json["status"],
    );
  }
}
