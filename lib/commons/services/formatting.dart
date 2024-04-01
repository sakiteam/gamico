import 'package:basic_utils/basic_utils.dart';

class FormattingService {
  static String formatNumber(int number) {
    String s = StringUtils.reverse(number.toString());
    s = StringUtils.addCharAtPosition(s, " ", 3, repeat: true);
    return StringUtils.reverse(s);
  }
}
