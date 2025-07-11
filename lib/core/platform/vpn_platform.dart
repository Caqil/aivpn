// lib/core/platform/vpn_platform.dart - Enhanced with better error handling
import 'dart:async';
import 'dart:math' as Math;
import 'package:flutter/services.dart';
import '../errors/exceptions.dart';
import '../../data/models/vpn_state_model.dart';

class VpnPlatform {
  static const MethodChannel _channel = MethodChannel('aivpn');
  static Stream<VpnConnectionModel>? _connectionStream;
  static bool _isInitialized = false;
  static StreamController<VpnConnectionModel>? _statusController;

  static Stream<VpnConnectionModel> get connectionStream {
    _connectionStream ??= _createConnectionStream();
    return _connectionStream!;
  }

  static Stream<VpnConnectionModel> _createConnectionStream() {
    _statusController = StreamController<VpnConnectionModel>.broadcast();

    // Set up method call handler for status updates from iOS
    _channel.setMethodCallHandler((call) async {
      print('📱 Received iOS method call: ${call.method}');
      print('📱 Arguments: ${call.arguments}');

      if (call.method == 'stateDidChangeNotification') {
        final arguments = call.arguments as Map<dynamic, dynamic>;
        final state = arguments['state'] as int;
        print('📱 VPN status changed to: $state (${_getStatusName(state)})');

        final vpnModel = _mapStatusToVpnModel(state);
        _statusController?.add(vpnModel);
      }
    });

    return _statusController!.stream;
  }

  /// Initialize VPN Manager with enhanced error handling
  static Future<bool> initialize() async {
    if (_isInitialized) {
      print('✅ VPN already initialized');
      return true;
    }

    try {
      print('🔄 Initializing VPN Manager...');
      await _channel.invokeMethod('initializeVPNManager');
      _isInitialized = true;
      print('✅ VPN Manager initialized successfully');

      // Get initial state after initialization
      final initialState = await getCurrentState();
      print('📊 Initial VPN state: ${initialState.status}');

      return true;
    } on PlatformException catch (e) {
      print('❌ Failed to initialize VPN Manager');
      print('❌ Error code: ${e.code}');
      print('❌ Error message: ${e.message}');
      print('❌ Error details: ${e.details}');
      throw VpnException('Failed to initialize VPN Manager: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error during initialization: $e');
      throw VpnException('Unexpected error during VPN initialization: $e');
    }
  }

  /// Connect to VPN with comprehensive error handling
  static Future<void> connect(String configUri) async {
    try {
      print('🔄 Starting VPN connection process...');
      print('🔗 Config URI: $configUri');
      print('🔗 URI length: ${configUri.length}');

      // Validate URI format
      if (!_isValidVpnUri(configUri)) {
        throw VpnException('Invalid VPN configuration URI format');
      }

      // Step 1: Ensure initialization
      if (!_isInitialized) {
        print('🔄 VPN not initialized, initializing now...');
        await initialize();
      }

      // Step 2: Check current state before connecting
      final currentState = await getCurrentState();
      print('📊 Current state before connect: ${currentState.status}');

      if (currentState.status == VpnStatus.connected) {
        print('⚠️ VPN already connected, disconnecting first...');
        await disconnect();
        await Future.delayed(const Duration(seconds: 2));
      }

      // Step 3: Parse the config to validate it
      try {
        print('🔄 Testing config parsing...');
        final configs = await parseUri(configUri);
        print('✅ Config parsed successfully: ${configs.length} configurations');
        if (configs.isEmpty) {
          throw VpnException('No valid configurations found in URI');
        }
      } catch (e) {
        print('❌ Config parsing failed: $e');
        // Continue anyway, as some URIs might not parse but still work for connection
      }

      // Step 4: Attempt connection
      print('🔄 Calling native connect method...');
      await _channel.invokeMethod('connect', {'uri': configUri});
      print('✅ Connect method called successfully');

      // Step 5: Monitor connection progress
      await _monitorConnectionProgress();
    } on PlatformException catch (e) {
      print('❌ Platform exception during connect');
      print('❌ Error code: ${e.code}');
      print('❌ Error message: ${e.message}');
      print('❌ Error details: ${e.details}');

      // Analyze specific error types
      String errorMessage = _analyzeConnectionError(e);
      throw VpnException(errorMessage);
    } catch (e) {
      print('❌ Unexpected error during connect: $e');
      throw VpnException('Unexpected error during VPN connection: $e');
    }
  }

  /// Monitor connection progress and detect issues
  static Future<void> _monitorConnectionProgress() async {
    print('🔄 Monitoring connection progress...');

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1));

      try {
        final state = await getCurrentState();
        print('📊 Connection progress check $i: ${state.status}');

        switch (state.status) {
          case VpnStatus.connected:
            print('✅ VPN connected successfully!');
            return;
          case VpnStatus.error:
            print('❌ VPN connection failed with error status');
            throw VpnException('VPN connection failed - error status detected');
          case VpnStatus.disconnected:
            if (i > 3) {
              // Give it some time before considering it failed
              print('❌ VPN connection failed - returned to disconnected state');
              throw VpnException(
                'VPN connection failed - unable to establish connection',
              );
            }
            break;
          case VpnStatus.connecting:
            print('🔄 Still connecting...');
            continue;
          case VpnStatus.disconnecting:
            print('⚠️ VPN is disconnecting during connection attempt');
            break;
        }
      } catch (e) {
        print('❌ Error during connection monitoring: $e');
        break;
      }
    }

    print('⏰ Connection monitoring timeout');
    throw VpnException('VPN connection timeout - took too long to connect');
  }

  /// Analyze connection errors and provide helpful messages
  static String _analyzeConnectionError(PlatformException e) {
    final code = e.code?.toLowerCase() ?? '';
    final message = e.message?.toLowerCase() ?? '';

    if (code.contains('permission') || message.contains('permission')) {
      return 'VPN permission denied. Please grant VPN permission in device settings.';
    }

    if (code.contains('network') || message.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    if (code.contains('config') || message.contains('config')) {
      return 'Invalid VPN configuration. Please check the server settings.';
    }

    if (code.contains('timeout') || message.contains('timeout')) {
      return 'Connection timeout. The VPN server may be unreachable.';
    }

    if (code.contains('auth') || message.contains('auth')) {
      return 'Authentication failed. Please check your VPN credentials.';
    }

    return 'VPN connection failed: ${e.message ?? "Unknown error"}';
  }

  /// Validate VPN URI format
  static bool _isValidVpnUri(String uri) {
    if (uri.isEmpty) return false;

    final validPrefixes = [
      'vmess://',
      'vless://',
      'trojan://',
      'ss://',
      'http://',
      'https://',
    ];
    return validPrefixes.any((prefix) => uri.startsWith(prefix));
  }

  /// Get human-readable status name
  static String _getStatusName(int status) {
    switch (status) {
      case 0:
        return 'Disconnected';
      case 1:
        return 'Connecting';
      case 2:
        return 'Connected';
      case 3:
        return 'Disconnecting';
      case 4:
        return 'Error';
      case -1:
        return 'Failed';
      default:
        return 'Unknown($status)';
    }
  }

  /// Disconnect with proper state monitoring
  static Future<void> disconnect() async {
    try {
      print('🔄 Disconnecting VPN...');
      await _channel.invokeMethod('disconnect');
      print('✅ Disconnect method called successfully');

      // Monitor disconnection
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        final state = await getCurrentState();
        if (state.status == VpnStatus.disconnected) {
          print('✅ VPN disconnected successfully');
          return;
        }
      }
    } on PlatformException catch (e) {
      print('❌ Failed to disconnect: ${e.message}');
      throw VpnException('Failed to disconnect from VPN: ${e.message}');
    }
  }

  /// Get current state with error handling
  static Future<VpnConnectionModel> getCurrentState() async {
    try {
      final result = await _channel.invokeMethod('activeState');
      final status = result as int;
      return _mapStatusToVpnModel(status);
    } on PlatformException catch (e) {
      print('❌ Failed to get VPN state: ${e.message}');
      throw VpnException('Failed to get current VPN state: ${e.message}');
    }
  }

  /// Parse URI with better error handling
  static Future<List<Map<String, dynamic>>> parseUri(String uri) async {
    try {
      print('🔄 Parsing URI: ${uri.substring(0, Math.min(50, uri.length))}...');
      final result = await _channel.invokeMethod('parseURI', {'uri': uri});

      if (result == null) {
        print('⚠️ Parse URI returned null');
        return [];
      }

      final configurations = List<Map<String, dynamic>>.from(result);
      print('✅ Parsed ${configurations.length} configurations');

      // Log first configuration for debugging (without sensitive data)
      if (configurations.isNotEmpty) {
        final firstConfig = Map<String, dynamic>.from(configurations.first);
        // Remove sensitive data from log
        firstConfig.remove('id');
        firstConfig.remove('password');
        print('📋 First configuration structure: ${firstConfig.keys.toList()}');
      }

      return configurations;
    } on PlatformException catch (e) {
      print('❌ Failed to parse URI: ${e.message}');
      throw VpnException('Failed to parse URI: ${e.message}');
    }
  }

  /// Enhanced status mapping with better error detection
  static VpnConnectionModel _mapStatusToVpnModel(int status) {
    VpnStatus vpnStatus;
    String? errorMessage;

    switch (status) {
      case 0:
        vpnStatus = VpnStatus.disconnected;
        break;
      case 1:
        vpnStatus = VpnStatus.connecting;
        break;
      case 2:
        vpnStatus = VpnStatus.connected;
        break;
      case 3:
        vpnStatus = VpnStatus.disconnecting;
        break;
      case 4:
      case -1:
        vpnStatus = VpnStatus.error;
        errorMessage = 'VPN connection failed';
        break;
      default:
        vpnStatus = VpnStatus.error;
        errorMessage = 'Unknown VPN status: $status';
        break;
    }

    return VpnConnectionModel(
      status: vpnStatus,
      errorMessage: errorMessage,
      connectedAt: vpnStatus == VpnStatus.connected ? DateTime.now() : null,
    );
  }

  /// Get detailed connection info for debugging
  static Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final state = await getCurrentState();
      final activeUrl = await getActiveUrl();

      return {
        'initialized': _isInitialized,
        'status': state.status.toString(),
        'activeUrl': activeUrl,
        'hasError': state.errorMessage != null,
        'errorMessage': state.errorMessage,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Keep existing methods
  static Future<bool> isConnected() async {
    try {
      final state = await getCurrentState();
      return state.status == VpnStatus.connected;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getActiveUrl() async {
    try {
      final result = await _channel.invokeMethod('activeURL');
      return result as String?;
    } on PlatformException catch (e) {
      print('❌ Failed to get active URL: ${e.message}');
      return null;
    }
  }

  static Future<Map<String, int>> getConnectionStats() async {
    try {
      final result = await _channel.invokeMethod('fetchStatistics');
      final stats = Map<String, dynamic>.from(result ?? {});

      return {
        'downloadlink': stats['downloadlink'] as int? ?? 0,
        'uploadlink': stats['uploadlink'] as int? ?? 0,
        'mdownloadlink': stats['mdownloadlink'] as int? ?? 0,
        'muploadlink': stats['muploadlink'] as int? ?? 0,
      };
    } on PlatformException catch (e) {
      print('❌ Failed to get connection stats: ${e.message}');
      return {};
    }
  }

  static Future<String> testConnection() async {
    try {
      final result = await _channel.invokeMethod('getPlatformVersion');
      return result as String;
    } on PlatformException catch (e) {
      throw VpnException('Platform test failed: ${e.message}');
    }
  }

  static void dispose() {
    _statusController?.close();
    _statusController = null;
    _connectionStream = null;
  }
}
