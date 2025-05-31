import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:safer_vpn/src/core/index.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late Future<User?> futureUser;
late Future<Logs?> futureLogsUser;
bool? showProgress = false;
String userToken = '';
String contactEmail = 'support@billiongroup.net';
String appStoreId = '6497651476';
Servers? userServer;
const String appName = '360 AI VPN';
const String urlPrivacy =
    'https://firebasestorage.googleapis.com/v0/b/sec-vpn-524ac.appspot.com/o/privacy_360.html?alt=media';
const String urlTerms =
    'https://firebasestorage.googleapis.com/v0/b/sec-vpn-524ac.appspot.com/o/term_360.html?alt=media';
const String providerBundleIdentifier = 'com.360aivpn.SAFExtension';

final bool autoConsume = Platform.isIOS || true;
const String consumableId = 'consumable';
String monthly360 =
    Platform.isIOS || Platform.isMacOS ? 'monthly_360' : 'monthly_360_android';
String yearly360 =
    Platform.isIOS || Platform.isMacOS ? 'yearly_360' : 'yearly_360_android';

List<String> listProductIds = <String>[
  consumableId,
  monthly360,
  yearly360,
];

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

String? validateEmail(String? value) {
  const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  final regex = RegExp(pattern);

  return value!.isNotEmpty && !regex.hasMatch(value)
      ? 'Enter a valid email address'
      : null;
}
