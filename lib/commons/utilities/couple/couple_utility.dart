import 'package:meta/meta.dart';

@immutable
class GamicoCoupleUtility<T> {
  final T first;
  final T last;

  const GamicoCoupleUtility(this.first, this.last);
}
