import 'package:gamico/commons/enums/message_type.dart';
import 'package:gamico/commons/utilities/message/concrete/awesome_message_utility.dart';
import 'package:gamico/commons/utilities/message/concrete/congratulations_message_utility.dart';
import 'package:gamico/commons/utilities/message/concrete/excellent_message_utility.dart';
import 'package:gamico/commons/utilities/message/concrete/good_message_utility.dart';
import 'package:gamico/commons/utilities/message/concrete/great_message_utility.dart';
import 'package:gamico/commons/utilities/message/concrete/magnificent_message_utility.dart';
import 'package:gamico/commons/utilities/message/concrete/masterful_message_utility.dart';

abstract class MessageUtility {
  abstract final String text;
  abstract final String voice;

  factory MessageUtility(MessageType type) {
    return switch (type) {
      MessageType.awesome => AwesomeMessageUtility(),
      MessageType.congratulations => CongratulationsMessageUtility(),
      MessageType.excellent => ExcellentMessageUtility(),
      MessageType.good => GoodMessageUtility(),
      MessageType.great => GreatMessageUtility(),
      MessageType.magnificent => MagnificentMessageUtility(),
      MessageType.masterful => MasterfulMessageUtility(),
    };
  }
}
