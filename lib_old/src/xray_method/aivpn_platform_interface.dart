import 'package:flutter/services.dart';
import 'aivpn_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AivpnPlatform extends PlatformInterface {
  /// Constructs a BossvpnPlatform.
  AivpnPlatform() : super(token: _token);

  static final Object _token = Object();

  static AivpnPlatform _instance = AivpnMethodChannel();

  /// The default instance of [AivpnPlatform] to use.
  ///
  /// Defaults to [AivpnMethodChannel].
  static AivpnPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AivpnPlatform] when
  /// they register themselves.
  static set instance(AivpnPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void connect(String uri) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  void disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  void updateURL(String uri) {
    throw UnimplementedError('updateURL() has not been implemented.');
  }

  void setGlobalMode(bool globalMode) {
    throw UnimplementedError('setGlobalMode() has not been implemented.');
  }

  Future<Object?> parseURI(String uri) {
    throw UnimplementedError('parseURI() has not been implemented.');
  }

  Future<String?> activeURL() {
    throw UnimplementedError('activeURL() has not been implemented.');
  }

  Future<String?> xrayVersion() {
    throw UnimplementedError('xrayVersion() has not been implemented.');
  }

  Future<int?> activeState() {
    throw UnimplementedError('activeState() has not been implemented.');
  }

  MethodChannel channel() {
    throw UnimplementedError('channel() has not been implemented.');
  }

  void initializeVPNManager() {
    throw UnimplementedError(
        'initializeVPNManager() has not been implemented.');
  }

  Future<Object?> fetchStatistics() {
    throw UnimplementedError('fetchStatistics() has not been implemented.');
  }
}
