import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/languages/languages.dart';

class MagnificentMessageUtility implements MessageUtility {
  @override
  String get text => GamicoLanguages.instance.magnificentMessage;

  @override
  String get voice => "magnificent";
}
