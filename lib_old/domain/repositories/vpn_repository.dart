import '../entities/server.dart';
import '../entities/vpn_connection.dart';

abstract class VpnRepository {
  Stream<VpnConnection> get connectionStream;
  Future<void> connect(Server server);
  Future<void> disconnect();
  Future<VpnConnection> getCurrentConnection();
  Future<bool> isConnected();
}
