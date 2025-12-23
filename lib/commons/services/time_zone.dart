import 'package:flutter_timezone/flutter_timezone.dart';

class TimeZoneService {
  static String timeZone = "Africa/Abidjan";

  static Future<void> initTimeZone() async {
    timeZone = (await FlutterTimezone.getLocalTimezone()).identifier;
  }
}
