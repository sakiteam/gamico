import 'package:flutter/cupertino.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class TimeZoneService {
  static String timeZone = "Africa/Abidjan";

  static Future<void> initTimeZone() async {
    try {
      timeZone = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (e) {
      debugPrint("$e");
    }
  }
}
