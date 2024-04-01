import 'package:meta/meta.dart';

@immutable
class GamicoPurchaseModel {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? userId;
  final String? productId;
  final String? purchaseId;

  final Map<String, dynamic>? error;
  final bool? pendingCompletion;
  final String? status;
  final String? transactionDate;
  final Map<String, dynamic>? verificationData;

  const GamicoPurchaseModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    //
    this.userId,
    this.productId,
    this.purchaseId,
    //
    this.error,
    this.pendingCompletion,
    this.status,
    this.transactionDate,
    this.verificationData,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "created_at": createdAt?.toString(),
      "updated_at": updatedAt?.toString(),
      //
      "user_id": userId,
      "product_id": productId,
      "purchase_id": purchaseId,
      //
      "error": error,
      "pending_completion": pendingCompletion,
      "status": status,
      "transaction_date": transactionDate,
      "verification_data": verificationData,
    };
  }

  factory GamicoPurchaseModel.fromJson(Map<String, dynamic> json) {
    return GamicoPurchaseModel(
      id: json["id"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      //
      userId: json["user_id"],
      productId: json["product_id"],
      purchaseId: json["purchase_id"],
      //
      error: json["error"] == null
          ? null
          : Map<String, dynamic>.from(json["error"]),
      pendingCompletion: bool.tryParse("${json["pending_completion"]}"),
      status: json["status"],
      transactionDate: json["transaction_date"],
      verificationData: json["verification_data"] == null
          ? null
          : Map<String, dynamic>.from(json["verification_data"]),
    );
  }
}
