import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/languages/languages.dart';

class GreatMessageUtility implements MessageUtility {
  @override
  String get text => GamicoLanguages.instance.greatMessage;

  @override
  String get voice => "great";
}
