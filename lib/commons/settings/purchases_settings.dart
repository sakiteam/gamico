import 'package:meta/meta.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';

@immutable
class PurchasesSettings {
  List<String> get packsIds => classicPacksIds + specialPacksIds;

  List<String> get classicPacksIds => classicPacks.keys.toList();
  List<String> get specialPacksIds => specialPacks.keys.toList();

  final Map<String, Function(GamicoUserCubit userCubit)> classicPacks;
  final Map<String, Function(GamicoUserCubit userCubit)> specialPacks;
  final String? premiumProductId;

  /// How many coins each pack, classic or special, gives. This is what lets the
  /// special offer show its real regular price — what the same coins cost in
  /// classic packs. Packs left out get no struck-through price.
  final Map<String, int> packsAmounts;

  const PurchasesSettings({
    this.classicPacks = const {},
    this.specialPacks = const {},
    this.premiumProductId,
    this.packsAmounts = const {},
  });
}
