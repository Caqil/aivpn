// lib/data/repositories/vpn_repository.dart - Updated to work with your native implementation
import '../../domain/entities/server.dart';
import '../../domain/entities/vpn_connection.dart';
import '../../domain/repositories/vpn_repository.dart';
import '../../core/platform/vpn_platform.dart';
import '../../core/errors/exceptions.dart';
import '../models/vpn_state_model.dart';

class VpnRepositoryImpl implements VpnRepository {
  @override
  Stream<VpnConnection> get connectionStream {
    return VpnPlatform.connectionStream.map((model) => _mapToEntity(model));
  }

  @override
  Future<void> connect(Server server) async {
    try {
      // Initialize VPN manager first (this may show permission dialogs)
      await VpnPlatform.initialize();

      // Use the server's config URL directly since your iOS code expects a URI
      String configUri;

      if (server.configUrl != null && server.configUrl!.isNotEmpty) {
        // Use the server's config URL if available
        configUri = server.configUrl!;
      } else {
        // Build a basic URI format if no config URL is provided
        // This is a fallback - ideally all servers should have configUrl
        configUri = _buildConfigUri(server);
      }

      print('Connecting to VPN with URI: $configUri');

      // Connect using the URI
      await VpnPlatform.connect(server.configUrl!);
    } on VpnException {
      rethrow;
    } catch (e) {
      throw VpnException('Failed to connect to server: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await VpnPlatform.disconnect();
    } on VpnException {
      rethrow;
    } catch (e) {
      throw VpnException('Failed to disconnect: $e');
    }
  }

  @override
  Future<VpnConnection> getCurrentConnection() async {
    try {
      final model = await VpnPlatform.getCurrentState();

      // Get additional connection info if connected
      if (model.status == VpnStatus.connected) {
        final activeUrl = await VpnPlatform.getActiveUrl();
        final stats = await VpnPlatform.getConnectionStats();

        return VpnConnection(
          status: model.status,
          serverId: model.serverId,
          serverName: model.serverName,
          serverCountry: model.serverCountry,
          errorMessage: model.errorMessage,
          connectedAt: model.connectedAt,
          connectionDuration: model.connectionDuration,
        );
      }

      return _mapToEntity(model);
    } on VpnException {
      rethrow;
    } catch (e) {
      throw VpnException('Failed to get current connection: $e');
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      return await VpnPlatform.isConnected();
    } on VpnException {
      rethrow;
    } catch (e) {
      throw VpnException('Failed to check connection status: $e');
    }
  }

  /// Get connection statistics
  Future<Map<String, int>> getConnectionStats() async {
    try {
      return await VpnPlatform.getConnectionStats();
    } catch (e) {
      throw VpnException('Failed to get connection stats: $e');
    }
  }

  /// Update VPN configuration
  // Future<void> updateConfiguration(String uri) async {
  //   try {
  //     await VpnPlatform.updateUrl(uri);
  //   } catch (e) {
  //     throw VpnException('Failed to update VPN configuration: $e');
  //   }
  // }

  // /// Set global mode for VPN
  // Future<void> setGlobalMode(bool enabled) async {
  //   try {
  //     await VpnPlatform.setGlobalMode(enabled);
  //   } catch (e) {
  //     throw VpnException('Failed to set global mode: $e');
  //   }
  // }

  /// Parse server configurations from URI
  Future<List<Server>> parseServerConfigurations(String uri) async {
    try {
      final configurations = await VpnPlatform.parseUri(uri);

      return configurations.map((config) {
        return Server(
          id: config['uri'] ?? '',
          name: config['ps'] ?? config['name'] ?? 'Unknown Server',
          country: _extractCountryFromConfig(config),
          address: config['add'] ?? config['address'] ?? '',
          port: config['port'] ?? 0,
          protocol: _extractProtocolFromUri(config['uri'] ?? ''),
          configUrl: config['uri'],
          isPremium: false,
          ping: config['rtt'] ?? 0,
        );
      }).toList();
    } catch (e) {
      throw VpnException('Failed to parse server configurations: $e');
    }
  }

  // Helper methods
  VpnConnection _mapToEntity(VpnConnectionModel model) {
    return VpnConnection(
      status: model.status,
      serverId: model.serverId,
      serverName: model.serverName,
      serverCountry: model.serverCountry,
      errorMessage: model.errorMessage,
      connectedAt: model.connectedAt,
      connectionDuration: model.connectionDuration,
    );
  }

  String _buildConfigUri(Server server) {
    // This is a fallback method to build a basic URI
    // Your servers should ideally have proper configUrl
    switch (server.protocol.toLowerCase()) {
      case 'vmess':
        return 'vmess://${server.address}:${server.port}';
      case 'vless':
        return 'vless://${server.address}:${server.port}';
      case 'trojan':
        return 'trojan://${server.address}:${server.port}';
      case 'shadowsocks':
      case 'ss':
        return 'ss://${server.address}:${server.port}';
      default:
        return '${server.protocol}://${server.address}:${server.port}';
    }
  }

  String _extractCountryFromConfig(Map<String, dynamic> config) {
    // Try to extract country from various fields
    if (config['country'] != null) return config['country'];
    if (config['ps'] != null) {
      // Parse country from ps (remark) field
      final ps = config['ps'] as String;
      return _parseCountryFromName(ps);
    }
    if (config['name'] != null) {
      final name = config['name'] as String;
      return _parseCountryFromName(name);
    }
    return 'Unknown';
  }

  String _parseCountryFromName(String name) {
    // Simple country extraction logic
    final lowerName = name.toLowerCase();

    final countryPatterns = {
      'us': 'United States',
      'usa': 'United States',
      'united states': 'United States',
      'uk': 'United Kingdom',
      'gb': 'United Kingdom',
      'de': 'Germany',
      'germany': 'Germany',
      'fr': 'France',
      'france': 'France',
      'jp': 'Japan',
      'japan': 'Japan',
      'sg': 'Singapore',
      'singapore': 'Singapore',
      'hk': 'Hong Kong',
      'hong kong': 'Hong Kong',
      'ca': 'Canada',
      'canada': 'Canada',
      'au': 'Australia',
      'australia': 'Australia',
      'nl': 'Netherlands',
      'netherlands': 'Netherlands',
    };

    for (final entry in countryPatterns.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'Unknown';
  }

  String _extractProtocolFromUri(String uri) {
    if (uri.startsWith('vmess://')) return 'vmess';
    if (uri.startsWith('vless://')) return 'vless';
    if (uri.startsWith('trojan://')) return 'trojan';
    if (uri.startsWith('ss://')) return 'shadowsocks';
    return 'unknown';
  }
}
