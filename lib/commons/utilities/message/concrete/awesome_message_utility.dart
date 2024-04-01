import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/languages/languages.dart';

class AwesomeMessageUtility implements MessageUtility {
  @override
  String get text => GamicoLanguages.instance.awesomeMessage;

  @override
  String get voice => "awesome";
}
