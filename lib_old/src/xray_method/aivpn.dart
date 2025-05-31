
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'aivpn_platform_interface.dart';

class Aivpn {
  static final ValueNotifier<String> _connectionNotifier =
      ValueNotifier<String>('Disconnected');

  static Future<dynamic> _handleCallback(MethodCall call) async {
    if (call.method == "stateDidChangeNotification") {
      final Map<dynamic, dynamic> dict = call.arguments;
      final int state = dict["state"];

      // Update the notifier based on the state
      if (state == 1) {
        // Connecting
        _connectionNotifier.value = 'Connecting';
      } else if (state == 2) {
        // Connected
        _connectionNotifier.value = 'Connected';
      } else if (state == 3) {
        // Disconnecting
        _connectionNotifier.value = 'Disconnecting';
      } else if (state == 4) {
        // Disconnected
        _connectionNotifier.value = 'Disconnected';
      }

      debugPrint("stateDidChangeNotification:$state");
    }
    return Future.value(true);
  }

  static void init() {
    AivpnPlatform.instance.channel().setMethodCallHandler(_handleCallback);
  }

  static ValueNotifier<String> get connectionNotifier => _connectionNotifier;
  // Other methods remain unchanged
  static Future<String?> getPlatformVersion() {
    return AivpnPlatform.instance.getPlatformVersion();
  }

  static void connect(String uri) {
    return AivpnPlatform.instance.connect(uri);
  }

  static void disconnect() {
    return AivpnPlatform.instance.disconnect();
  }

  static void updateURL(String uri) {
    return AivpnPlatform.instance.updateURL(uri);
  }

  static void setGlobalMode(bool globalMode) {
    return AivpnPlatform.instance.setGlobalMode(globalMode);
  }

  static Future<Object?> parseURI(String uri) {
    return AivpnPlatform.instance.parseURI(uri);
  }

  static Future<String?> activeURL() {
    return AivpnPlatform.instance.activeURL();
  }

  static Future<String?> xrayVersion() {
    return AivpnPlatform.instance.xrayVersion();
  }

  static Future<int?> activeState() {
    return AivpnPlatform.instance.activeState();
  }

  static void initializeVPNManager() {
    return AivpnPlatform.instance.initializeVPNManager();
  }

  static Future<Object?> fetchStatistics() {
    return AivpnPlatform.instance.fetchStatistics();
  }

  static String getConnectionStatus() {
    return connectionNotifier.value; // Return current connection state
  }
}
