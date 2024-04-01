import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/timestamp.dart';

class GratificationService {
  static DateTime? gratifiedAt;

  static DateTime get lastOneTimeOfferPurchaseDate =>
      DateTime.tryParse(
          LocalStorageService.getString("last_one_time_offer_purchase_date") ??
              "") ??
      DateTime(2000);
  static set lastOneTimeOfferPurchaseDate(DateTime value) {
    LocalStorageService.setString(
        "last_one_time_offer_purchase_date", value.toString());
  }

  static Duration getSpecialOfferRemainingDuration() {
    final initialDate = DateTime(2022, 11, 1);
    final now = DateTime.now();
    // bool enabled;

    final differenceDuration =
        TimestampService.getDatesMidnightDifference(initialDate, now);

    final daysDifference = differenceDuration.inDays % 3;
    final remainingDays = 3 - daysDifference;

    final Duration remainingDuration;

    final lastOneTimeOfferPurchaseDateAtMidnight =
        TimestampService.getDateMidnight(lastOneTimeOfferPurchaseDate);
    final todayAtMidnight = TimestampService.getDateMidnight(now);

    if (daysDifference == 0 &&
        todayAtMidnight
                .difference(lastOneTimeOfferPurchaseDateAtMidnight)
                .inSeconds !=
            0) {
      remainingDuration = Duration.zero;
    } else {
      remainingDuration = DateTime(now.year, now.month, now.day + remainingDays)
          .difference(now);
    }

    return remainingDuration;
  }
}
