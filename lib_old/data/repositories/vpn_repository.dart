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
      // Build config string from server data
      final config = _buildConfigString(server);
      await VpnPlatform.connect(config);
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

  String _buildConfigString(Server server) {
    // This would typically build a config string based on the server protocol
    // For now, returning the configUrl or a placeholder
    if (server.configUrl != null) {
      return server.configUrl!;
    }

    // Build basic config based on server data
    return '${server.protocol}://${server.address}:${server.port}';
  }
}
