import 'dart:io';

import 'package:flutter/services.dart';

class OVPN {
  static const String _methodChannelVpnControl = "com.360aivpn/vpncontrol";
  static const _eventChannelVpnStage = 'com.360aivpn/vpnstage';
  static const EventChannel _eventChannel = EventChannel(_eventChannelVpnStage);

  static Stream<String> vpnStageSnapshot() => _eventChannel
      .receiveBroadcastStream()
      .map((event) => event == vpnDenied ? vpnDisconnected : event);

  static Future<String> initialize() async {
    return const MethodChannel(_methodChannelVpnControl)
        .invokeMethod("initialize", {
      "groupIdentifier": "group.com.app.360aivpn",
      "providerBundleIdentifier": "com.360aivpn.360Extension",
      "localizedDescription": "360 AI VPN",
    }).then((value) {
      return OVPN.stage();
    });
  }

  static Future<void> startVpn(String ovpnConfig, String country) async {
    if (Platform.isIOS || Platform.isMacOS) {
      await initialize();
    }
    const MethodChannel(_methodChannelVpnControl).invokeMethod("start", {
      "config": ovpnConfig,
      "country": country,
      "username": "",
      "password": "",
    }).then((value) {});
  }

  static Future<void> stopVpn() =>
      const MethodChannel(_methodChannelVpnControl).invokeMethod("stop");
  static Future<void> openKillSwitch() =>
      const MethodChannel(_methodChannelVpnControl).invokeMethod("kill_switch");
  static Future<void> refreshStage() =>
      const MethodChannel(_methodChannelVpnControl).invokeMethod("refresh");
  static Future<String> stage() => const MethodChannel(_methodChannelVpnControl)
      .invokeMethod("stage")
      .then((value) => value ?? vpnDisconnected);
  static Future<bool> isConnected() =>
      stage().then((value) => value.toLowerCase() == vpnConnected);

  static const String vpnConnected = "connected";
  static const String vpnDisconnecting = "disconnecting";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNoConnection = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPrepare = "prepare";
  static const String vpnDenied = "denied";
  static const String vpnExiting = "exiting";
}
