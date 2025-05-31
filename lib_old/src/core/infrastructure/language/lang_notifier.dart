import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/core/domain/models/language.dart';
import 'package:safer_vpn/src/core/infrastructure/shared_preferences/store_preferences.dart';

class LangController extends ChangeNotifier {
  Locale? selectedLocale;

  List<Language>? languages = [];
  List<Locale>? locales = [
    const Locale("en", "US"),
    const Locale("id", "ID"),
    const Locale("zh", "CN"),
    const Locale("vi", "VN"),
    const Locale("de", "DE"),
    const Locale('hi', 'IN'),
    const Locale('pt', 'PT'),
    const Locale('ru', 'RU'),
    const Locale('bn', 'BD'),
    const Locale('ar', 'AR'),
  ];

  Future<void> setLanguage(BuildContext context, Locale locale) async {
    EasyLocalization.of(context)!.setLocale(locale);
    selectedLocale = locale;
    StorePreferences.getInit().then((value) {
      value.saveLocale(locale);
    });
    notifyListeners();
  }

  static void initializeLanguages(BuildContext context) async {
    var load = await DefaultAssetBundle.of(context)
        .loadString("assets/languages/env.json");
    LangController provider = LangController.instance(context);
    provider.languages = (jsonDecode(load))
        .map((e) => Language.fromJson(e))
        .toList()
        .cast<Language>();
    provider.locales = provider.languages!
        .map((e) => Locale(e.languageCode!, e.countryCode))
        .toList();

    StorePreferences.getInit().then((value) {
      if (value.locale != null) provider.setLanguage(context, value.locale!);
    });
    provider.notifyListeners();
  }

  static LangController instance(BuildContext context) =>
      Provider.of(context, listen: false);
}
