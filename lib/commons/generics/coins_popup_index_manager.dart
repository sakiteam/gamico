import 'package:gamico/commons/services/local_storage.dart';

/// Manages the page index and persistence for the coins/store popup.
class CoinsPopupIndexManager {
  const CoinsPopupIndexManager._();

  static const String _storageKey = "coins_popup_index";

  /// The persisted page index from previous sessions.
  static int get savedIndex => LocalStorageService.getInt(_storageKey) ?? 0;

  static set savedIndex(int value) =>
      LocalStorageService.setInt(_storageKey, value);

  /// Resolves the optimal initial page index based on player state:
  /// 1. Prioritizes gratification (rewards) if available.
  /// 2. Prioritizes the store page if the player lacks enough coins.
  /// 3. Otherwise restores the last visited tab.
  static int resolveInitialIndex({
    required int userCoins,
    required bool gratificationEnabled,
    int? minimumRequiredCoins,
  }) {
    if (gratificationEnabled) {
      return 0;
    }
    if (minimumRequiredCoins != null && userCoins < minimumRequiredCoins) {
      return 1;
    }
    return savedIndex;
  }
}
