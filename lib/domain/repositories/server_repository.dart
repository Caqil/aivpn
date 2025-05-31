import '../entities/server.dart';

abstract class ServerRepository {
  Future<List<Server>> getServers();
  Future<void> saveSelectedServer(Server server);
  Future<Server?> getSelectedServer();
  Future<void> clearSelectedServer();
  Future<List<Server>> getFavoriteServers();
  Future<void> addToFavorites(Server server);
  Future<void> removeFromFavorites(String serverId);
}
