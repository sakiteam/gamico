import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:gamico/commons/analytics/analytics_utils.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_purchase_model.dart';
import 'package:gamico/commons/repositories/gamico_purchases_repository.dart';
import 'package:gamico/commons/services/global.dart';

import 'package:flutter/material.dart';
import 'package:gamico/commons/services/gratification.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:gamico/commons/services/user.dart';
part 'purchases_state.dart';

class PurchasesCubit extends Cubit<PurchasesState> {
  PurchasesCubit({required this.userCubit, required this.purchasesRepository})
    : super(const PurchasesState()) {
    _initialize();
  }

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription? _subscription;

  final GamicoUserCubit userCubit;
  final GamicoPurchasesRepository purchasesRepository;

  void _initialize() async {
    emit(state.copyWith(status: PurchasesStatus.loading));

    if (await _iap.isAvailable()) {
      await _getProducts();

      emit(state.copyWith(status: PurchasesStatus.success));

      _subscription = _iap.purchaseStream.listen((purchases) async {
        for (final purchase in purchases) {
          // print("S === " +
          //     purchase.pendingCompletePurchase.toString() +
          //     purchase.transactionDate.toString());

          final product = _getProductById(purchase.productID);

          switch (purchase.status) {
            case PurchaseStatus.purchased:
              logEvent(
                name: "iap_completed",
                parameters: {"product": product.title},
              );

              _confirmPurchase(purchase);
              break;
            case PurchaseStatus.pending:
              // case PurchaseStatus.restored:
              // _confirmPurchase(purchase);
              break;
            case PurchaseStatus.canceled:
              logEvent(
                name: "iap_canceled",
                parameters: {"product": product.title},
              );

              resetStatus();
              break;
            case PurchaseStatus.error:
              emit(state.copyWith(status: PurchasesStatus.transactionFailure));
              break;
            case PurchaseStatus.restored:
              if (purchase.productID ==
                  Gamico.instance.purchasesSettings?.premiumProductId) {
                _confirmPurchase(purchase);
              }
              break;
          }
        }
      });

      // _iap.restorePurchases();
    } else {
      emit(state.copyWith(status: PurchasesStatus.failure));
    }
  }

  Future<void> _confirmPurchase(PurchaseDetails purchase) async {
    await GamicoGlobalService.waitWhile(
      () => !UserService.authenticated,
      const Duration(seconds: 5),
    );

    try {
      final error = purchase.error;
      final verificationData = purchase.verificationData;

      await Future.wait([
        _iap.completePurchase(purchase),
        purchasesRepository.createPurchase(
          GamicoPurchaseModel(
            userId: UserService.uid,
            productId: purchase.productID,
            purchaseId: purchase.purchaseID,
            error: error == null
                ? null
                : {
                    "code": error.code,
                    "details": error.details,
                    "message": error.message,
                    "source": error.source,
                  },
            pendingCompletion: purchase.pendingCompletePurchase,
            status: purchase.status.name.toUpperCase(),
            transactionDate: purchase.transactionDate,
            verificationData: {
              "local": verificationData.localVerificationData,
              "server": verificationData.serverVerificationData,
              "source": verificationData.source,
            },
          ),
        ),
      ]);

      if (Gamico.instance.purchasesSettings?.specialPacksIds.contains(
            purchase.productID,
          ) ==
          true) {
        GratificationService.lastOneTimeOfferPurchaseDate = DateTime.now();
      }

      if (purchase.productID ==
          Gamico.instance.purchasesSettings?.premiumProductId) {
        userCubit.setPremium();
      }

      // Reward user whether the pack is classic or special
      Gamico.instance.purchasesSettings?.classicPacks[purchase.productID]?.call(
        userCubit,
      );
      Gamico.instance.purchasesSettings?.specialPacks[purchase.productID]?.call(
        userCubit,
      );

      emit(state.copyWith(status: PurchasesStatus.transactionSuccess));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getProducts() async {
    final premiumId = Gamico.instance.purchasesSettings?.premiumProductId;
    Set<String> ids = {
      ...Gamico.instance.purchasesSettings?.packsIds.toSet() ?? {},
      ?premiumId,
    };
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    emit(state.copyWith(products: response.productDetails));
  }

  ProductDetails _getProductById(String id) {
    return state.products.firstWhere((element) => element.id == id);
  }

  ProductDetails? getPremiumProduct() {
    final id = Gamico.instance.purchasesSettings?.premiumProductId;
    if (id == null) return null;
    final matching = state.products.where((p) => p.id == id);
    return matching.isEmpty ? null : matching.first;
  }

  Future<void> purchase(ProductDetails product) async {
    emit(state.copyWith(status: PurchasesStatus.transactionLoading));

    try {
      await _iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      debugPrint(e.toString());

      emit(state.copyWith(status: PurchasesStatus.transactionFailure));
    }
  }

  Future<void> buyPremium() async {
    final product = getPremiumProduct();
    if (product == null) return;

    emit(state.copyWith(status: PurchasesStatus.transactionLoading));

    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(status: PurchasesStatus.transactionFailure));
    }
  }

  Future<void> restorePremiumPurchases() async {
    await _iap.restorePurchases();
  }

  void resetStatus() {
    emit(state.copyWith(status: PurchasesStatus.success));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
