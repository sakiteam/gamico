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

  /// Reads a stamp several devices must agree on — a game node's
  /// `created_at`, which seeds every online shuffle — as the same instant on
  /// all of them, whatever their timezone.
  ///
  /// Those stamps were long written as a zone-less `DateTime.toString()`
  /// (the creator's wall clock, or UTC components from the matchmaking
  /// Function), and `DateTime.tryParse` reads a zone-less string as LOCAL
  /// time: a room created in Abidjan and opened in Toronto yielded two
  /// instants four hours apart, hence two different seeds and two different
  /// deals at the same table. A zone-less stamp is therefore read as UTC
  /// here. On a GMT+0 device that is exactly what a plain parse gives, so
  /// builds predating this still agree with those devices. A stamp carrying
  /// its own `Z` or offset is unambiguous and parsed as is.
  static DateTime? parseShared(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    final parsed = DateTime.tryParse(text);
    if (parsed == null || parsed.isUtc) return parsed;
    // Appending the designator rather than rebuilding from [parsed]'s fields:
    // a wall-clock time that does not exist locally (a DST spring-forward
    // gap) has already been shifted by the local parse.
    return DateTime.tryParse("${text}Z") ??
        DateTime.utc(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
          parsed.millisecond,
          parsed.microsecond,
        );
  }

  /// The current time as a stamp other devices will read back: UTC, with its
  /// `Z` ("2026-09-30 14:00:00.123456Z"). Every build parses that as the same
  /// instant, including the ones that read zone-less stamps as local time.
  /// Same layout as `DateTime.toString()`, so it still sorts against the
  /// cleanup Function's string cutoffs.
  static String sharedNow() => DateTime.now().toUtc().toString();
}
