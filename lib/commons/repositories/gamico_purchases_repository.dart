import 'package:gamico/commons/models/gamico_purchase_model.dart';
import 'package:gamico/commons/providers/gamico_purchases_provider.dart';

class GamicoPurchasesRepository {
  final GamicoPurchasesProvider purchasesProvider;

  GamicoPurchasesRepository({
    required this.purchasesProvider,
  });

  Future<String> createPurchase(GamicoPurchaseModel purchase) async {
    return await purchasesProvider.createPurchase(purchase.toJson());
  }

  Future<GamicoPurchaseModel> readPurchase(String id) async {
    return GamicoPurchaseModel.fromJson(
        await purchasesProvider.readPurchase(id));
  }

  Future<void> updatePurchase(String id, GamicoPurchaseModel purchase) async {
    await purchasesProvider.updatePurchase(id, purchase.toJson());
  }

  Future<void> deletePurchase(String id) async {
    await purchasesProvider.deletePurchase(id);
  }
}
