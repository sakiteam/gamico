import 'package:gamico/commons/services/local_storage.dart';

class MusicService {
  static bool pausedByAd = false;

  /// Before music and sound effects could be muted apart, one "mute" key held
  /// both. It still seeds the two new keys until they have been written once,
  /// so an update keeps whatever the player had chosen.
  static bool get _legacyMute => LocalStorageService.getBool("mute") ?? false;

  static bool get musicMute =>
      LocalStorageService.getBool("mute_music") ?? _legacyMute;
  static set musicMute(bool value) =>
      LocalStorageService.setBool("mute_music", value);

  static bool get bruitagesMute =>
      LocalStorageService.getBool("mute_bruitages") ?? _legacyMute;
  static set bruitagesMute(bool value) =>
      LocalStorageService.setBool("mute_bruitages", value);

  /// Everything silenced: music and sound effects.
  static bool get mute => musicMute && bruitagesMute;
  static set mute(bool value) {
    musicMute = value;
    bruitagesMute = value;
  }
}
