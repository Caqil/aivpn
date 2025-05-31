import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class StorePreferences {
  final SharedPreferences shared;
  StorePreferences(this.shared);
  String? get userToken => shared.getString("user_token");
  String? get protocol => shared.getString("protocol");
  bool get privacyPolicy => shared.getBool("privacy-policy") ?? false;
  Locale? get locale => shared.getString("lang_code") == null
      ? null
      : Locale(shared.getString("lang_code") ?? "en",
          shared.getString("country_code"));

  Future saveLocale(Locale locale) async {
    shared.setString("lang_code", locale.languageCode);
    if (locale.countryCode != null) {
      shared.setString("country_code", locale.countryCode!);
    }
  }

  Future acceptPrivacyPolicy() {
    return shared.setBool("privacy-policy", true);
  }

  static Future<StorePreferences> instance() =>
      SharedPreferences.getInstance().then((value) => StorePreferences(value));
  static Future<StorePreferences> getInit() =>
      SharedPreferences.getInstance().then((value) => StorePreferences(value));
}
