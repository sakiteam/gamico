import 'package:flutter/material.dart';
import 'package:gamico/commons/services/local_storage.dart';

class LocaleService {
  static late Locale currentLocale;

  static String get language => LocalStorageService.getString("language") ?? "";
  static set language(String value) {
    LocalStorageService.setString("language", value);
  }
}
