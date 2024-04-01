import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/languages/languages.dart';

class ExcellentMessageUtility implements MessageUtility {
  @override
  String get text => GamicoLanguages.instance.excellentMessage;

  @override
  String get voice => "excellent";
}
