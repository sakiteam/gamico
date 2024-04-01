class TimestampService {
  static DateTime getDateMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static Duration getDatesMidnightDifference(DateTime d1, DateTime d2) {
    final date1 = DateTime(d1.year, d1.month, d1.day);
    final date2 = DateTime(d2.year, d2.month, d2.day);

    return date2.difference(date1);
  }

  static String getCountdownString(Duration duration) {
    final hours = getTimestampDigit(duration.inHours);
    final minutes = getTimestampDigit(duration.inMinutes.remainder(60));
    final seconds = getTimestampDigit(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  static String getTimestampDigit(int n) => n.toString().padLeft(2, '0');

  static Duration durationToNextHour() {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    return nextHour.difference(now);
  }
}
