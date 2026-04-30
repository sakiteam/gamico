import 'package:meta/meta.dart';
import 'package:gamico/commons/global/gamico.dart';

@immutable
class GamicoUserModel {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? token;
  final String? name;
  final String? formattedName;
  final String? type;
  final String? photo;
  final String? firebaseId;
  final String? socialId;
  final bool? blocked;
  final String? referrerId;
  final bool? online;
  final int? defeats;
  final int? victories;
  final Map<String, int>? achievements;
  final int? level;
  final List<int>? stars;
  final DateTime? gratifiedAt;
  final int? coins;
  final int? trophies;
  final int? lastGratification;
  final int? nextGratification;
  final Map<String, dynamic>? progression;
  final Map<String, dynamic>? skins;
  final bool? premium;

  bool? get broke {
    return coins == null
        ? null
        : (coins! < Gamico.instance.gameSettings.playMinimumCoins) &&
              !Gamico.instance.gameSettings.ignoreMinimumCoinsToPlay;
  }

  const GamicoUserModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.token,
    this.name,
    this.formattedName,
    this.type,
    this.photo,
    this.level,
    this.victories,
    this.defeats,
    this.achievements,
    this.firebaseId,
    this.socialId,
    this.blocked,
    this.referrerId,
    this.online,
    this.stars,
    this.gratifiedAt,
    this.coins,
    this.trophies,
    this.lastGratification,
    this.nextGratification,
    this.skins,
    this.progression,
    this.premium,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "created_at": createdAt?.toString(),
      "updated_at": updatedAt?.toString(),
      "token": token,
      "name": name,
      "formatted_name": formattedName,
      "type": type,
      "photo": photo,
      "coins": coins,
      "level": level,
      "victories": victories,
      "defeats": defeats,
      "trophies": trophies,
      "achievements": achievements,
      "firebase_id": firebaseId,
      "social_id": socialId,
      "blocked": blocked,
      "last_gratification": lastGratification,
      "next_gratification": nextGratification,
      "gratified_at": gratifiedAt?.toString(),
      "referrer_id": referrerId,
      "online": online,
      "stars": stars,
      "skins": skins,
      "progression": progression,
      "premium": premium,
    };
  }

  factory GamicoUserModel.fromJson(Map<String, dynamic> json) {
    return GamicoUserModel(
      id: json["id"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      token: json["token"],
      name: json["name"],
      formattedName: json["formatted_name"],
      type: json["type"],
      photo: json["photo"],
      coins: json["coins"]?.toInt(),
      level: json["level"]?.toInt(),
      victories: json["victories"]?.toInt(),
      defeats: json["defeats"]?.toInt(),
      trophies: json["trophies"]?.toInt(),
      achievements: json["achievements"]?.map<String, int>(
        (key, value) => MapEntry<String, int>(
          key.toString(),
          int.tryParse(value.toString()) ?? 0,
        ),
      ),
      firebaseId: json["firebase_id"],
      socialId: json["social_id"],
      blocked: json["blocked"],
      lastGratification: json["last_gratification"]?.toInt(),
      nextGratification: json["next_gratification"]?.toInt(),
      gratifiedAt: DateTime.tryParse(json["gratified_at"] ?? ""),
      referrerId: json["referrer_id"],
      online: json["online"],
      stars: (json["stars"] as List?)?.map<int>((e) {
        return e.toInt();
      }).toList(),
      skins: json["skins"],
      progression: json["progression"],
      premium: json["premium"],
    );
  }
}
