import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/languages/languages.dart';

class GoodMessageUtility implements MessageUtility {
  @override
  String get text => GamicoLanguages.instance.goodMessage;

  @override
  String get voice => "good";
}
