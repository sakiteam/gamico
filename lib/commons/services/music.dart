import 'package:gamico/commons/services/local_storage.dart';

class MusicService {
  static bool pausedByAd = false;

  static bool get mute => LocalStorageService.getBool("mute") ?? false;
  static set mute(bool value) => LocalStorageService.setBool("mute", value);
}
