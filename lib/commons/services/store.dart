import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreService {
  /// Opens the application's store page.
  ///
  /// On iOS, [StoreRedirect.redirect] throws a native
  /// NSInvalidArgumentException when no app id is provided, so the id is
  /// resolved from [Gamico.instance.storeSettings] first.
  static Future<void> openStorePage() async {
    try {
      if (Platform.isIOS) {
        final link = Gamico.instance.storeSettings?.iOSLink ?? "";
        final id = RegExp(r'id(\d+)').firstMatch(link)?.group(1);

        if (id != null) {
          await StoreRedirect.redirect(iOSAppId: id);
        } else if (link.isNotEmpty) {
          await launchUrl(
            Uri.parse(link),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        await StoreRedirect.redirect();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
