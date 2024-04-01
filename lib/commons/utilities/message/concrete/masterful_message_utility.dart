import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/languages/languages.dart';

class MasterfulMessageUtility implements MessageUtility {
  @override
  String get text => GamicoLanguages.instance.masterfulMessage;

  @override
  String get voice => "masterful";
}
