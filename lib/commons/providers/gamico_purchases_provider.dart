import 'package:gamico/commons/providers/gamico_generic_provider.dart';

class GamicoPurchasesProvider extends GamicoGenericProvider {
  Future<String> createPurchase(Map<String, dynamic> doc) {
    return createData("purchases", doc);
  }

  Future<Map<String, dynamic>> readPurchase(String id) {
    return readData("purchases", id);
  }

  Future<void> updatePurchase(String id, Map<String, dynamic> doc) {
    return updateData("purchases", id, doc);
  }

  Future<void> deletePurchase(String id) {
    return deleteData("purchases", id);
  }
}
