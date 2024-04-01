import 'package:meta/meta.dart';

@immutable
class GratificationSettings {
  final int hour1Gratification;
  final int hour2Gratification;
  final int hour3Gratification;

  const GratificationSettings({
    this.hour1Gratification = 3,
    this.hour2Gratification = 6,
    this.hour3Gratification = 9,
  });
}
