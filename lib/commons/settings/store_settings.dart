import 'package:meta/meta.dart';

@immutable
class StoreSettings {
  final String iOSLink;
  final String androidLink;

  const StoreSettings({
    required this.iOSLink,
    required this.androidLink,
  });
}
