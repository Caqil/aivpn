import 'dart:async';
import 'package:flutter/services.dart';
import '../errors/exceptions.dart';
import '../../data/models/vpn_state_model.dart';

class VpnPlatform {
  static const MethodChannel _channel = MethodChannel('vpn_app/vpn');
  static const EventChannel _eventChannel = EventChannel('vpn_app/vpn_events');

  static Stream<VpnConnectionModel>? _connectionStream;

  static Stream<VpnConnectionModel> get connectionStream {
    _connectionStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => _parseVpnEvent(event))
        .handleError((error) {
      throw VpnException('Connection stream error: $error');
    });
    return _connectionStream!;
  }

  static Future<void> connect(String config) async {
    try {
      await _channel.invokeMethod('connect', {'config': config});
    } on PlatformException catch (e) {
      throw VpnException('Failed to connect: ${e.message}');
    }
  }

  static Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      throw VpnException('Failed to disconnect: ${e.message}');
    }
  }

  static Future<VpnConnectionModel> getCurrentState() async {
    try {
      final result = await _channel.invokeMethod('getCurrentState');
      return _parseVpnState(result);
    } on PlatformException catch (e) {
      throw VpnException('Failed to get current state: ${e.message}');
    }
  }

  static Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod('isConnected');
      return result as bool;
    } on PlatformException catch (e) {
      throw VpnException('Failed to check connection status: ${e.message}');
    }
  }

  static VpnConnectionModel _parseVpnEvent(dynamic event) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(event);
    return _parseVpnState(data);
  }

  static VpnConnectionModel _parseVpnState(Map<String, dynamic> data) {
    final statusString = data['status'] as String? ?? 'disconnected';
    final status = _parseVpnStatus(statusString);

    return VpnConnectionModel(
      status: status,
      serverId: data['serverId'] as String?,
      serverName: data['serverName'] as String?,
      serverCountry: data['serverCountry'] as String?,
      errorMessage: data['errorMessage'] as String?,
      connectedAt: data['connectedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['connectedAt'])
          : null,
    );
  }

  static VpnStatus _parseVpnStatus(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return VpnStatus.connected;
      case 'connecting':
        return VpnStatus.connecting;
      case 'disconnected':
        return VpnStatus.disconnected;
      case 'disconnecting':
        return VpnStatus.disconnecting;
      case 'error':
        return VpnStatus.error;
      default:
        return VpnStatus.disconnected;
    }
  }
}
