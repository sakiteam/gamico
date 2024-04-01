import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/languages/languages.dart';

class CongratulationsMessageUtility implements MessageUtility {
  @override
  String get text => GamicoLanguages.instance.congratulationsMessage;

  @override
  String get voice => "congratulations";
}
