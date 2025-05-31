import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'aivpn_platform_interface.dart';

class AivpnMethodChannel extends AivpnPlatform {
  final methodChannel = const MethodChannel('bgtunnel');

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final version =
          await methodChannel.invokeMethod<String>('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      debugPrint("Failed to get platform version: '${e.message}'.");
      return null;
    }
  }

  @override
  Future<void> connect(String uri) async {
    try {
      await methodChannel.invokeMethod('connect', {'uri': uri});
    } on PlatformException catch (e) {
      debugPrint("Failed to connect: '${e.message}'.");
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await methodChannel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      debugPrint("Failed to disconnect: '${e.message}'.");
    }
  }

  @override
  Future<void> updateURL(String uri) async {
    try {
      await methodChannel.invokeMethod('updateURL', {'uri': uri});
    } on PlatformException catch (e) {
      debugPrint("Failed to update URL: '${e.message}'.");
    }
  }

  @override
  Future<void> setGlobalMode(bool globalMode) async {
    try {
      await methodChannel
          .invokeMethod('setGlobalMode', {'globalMode': globalMode});
    } on PlatformException catch (e) {
      debugPrint("Failed to set global mode: '${e.message}'.");
    }
  }

  @override
  Future<Object?> parseURI(String uri) async {
    try {
      final result =
          await methodChannel.invokeMethod<Object?>('parseURI', {'uri': uri});
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to parse URI: '${e.message}'.");
      return null;
    }
  }

  @override
  Future<String?> activeURL() async {
    try {
      final url = await methodChannel.invokeMethod<String?>('activeURL');
      return url;
    } on PlatformException catch (e) {
      debugPrint("Failed to get active URL: '${e.message}'.");
      return null;
    }
  }

  @override
  Future<String?> xrayVersion() async {
    try {
      final url = await methodChannel.invokeMethod<String?>('xrayVersion');
      return url;
    } on PlatformException catch (e) {
      debugPrint("Failed to get xrayVersion: '${e.message}'.");
      return null;
    }
  }

  @override
  Future<int?> activeState() async {
    try {
      final state = await methodChannel.invokeMethod<int?>('activeState');
      return state;
    } on PlatformException catch (e) {
      debugPrint("Failed to get active state: '${e.message}'.");
      return null;
    }
  }

  @override
  Future<void> initializeVPNManager() async {
    try {
      await methodChannel.invokeMethod('initializeVPNManager');
    } on PlatformException catch (e) {
      debugPrint("Failed to initialize VPN Manager: '${e.message}'.");
    }
  }

  @override
  Future<Object?> fetchStatistics() async {
    try {
      final stats =
          await methodChannel.invokeMethod<Object?>('fetchStatistics');
      return stats;
    } on PlatformException catch (e) {
      debugPrint("Failed to fetch statistics: '${e.message}'.");
      return null;
    }
  }

  @override
  MethodChannel channel() {
    return methodChannel;
  }
}
