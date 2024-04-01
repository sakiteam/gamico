part of 'purchases_cubit.dart';

enum PurchasesStatus {
  initial,
  loading,
  success,
  failure,

  transactionInitial,
  transactionLoading,
  transactionFailure,
  transactionSuccess,
}

@immutable
class PurchasesState {
  final List<PurchaseDetails?> purchases;
  final bool available;
  final List<ProductDetails> products;
  final PurchasesStatus status;

  const PurchasesState({
    this.purchases = const [],
    this.available = true,
    this.products = const [],
    this.status = PurchasesStatus.initial,
  });

  PurchasesState copyWith({
    List<PurchaseDetails?>? purchases,
    bool? available,
    List<ProductDetails>? products,
    PurchasesStatus? status,
  }) {
    return PurchasesState(
      purchases: purchases ?? this.purchases,
      available: available ?? this.available,
      products: products ?? this.products,
      status: status ?? this.status,
    );
  }
}
