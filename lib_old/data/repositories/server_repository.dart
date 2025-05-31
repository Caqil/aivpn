import '../../domain/entities/server.dart';
import '../../domain/repositories/server_repository.dart';
import '../datasources/server_api.dart';
import '../datasources/local_storage.dart';
import '../models/server_model.dart';
import '../../core/errors/exceptions.dart';

class ServerRepositoryImpl implements ServerRepository {
  final ServerApi serverApi;
  final LocalStorage localStorage;

  ServerRepositoryImpl({
    required this.serverApi,
    required this.localStorage,
  });

  @override
  Future<List<Server>> getServers() async {
    try {
      final serverModels = await serverApi.getServers();
      return serverModels.map((model) => model.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get servers: $e');
    }
  }

  @override
  Future<void> saveSelectedServer(Server server) async {
    try {
      final serverModel = ServerModel.fromEntity(server);
      await localStorage.saveSelectedServer(serverModel);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to save selected server: $e');
    }
  }

  @override
  Future<Server?> getSelectedServer() async {
    try {
      final serverModel = await localStorage.getSelectedServer();
      return serverModel?.toEntity();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get selected server: $e');
    }
  }

  @override
  Future<void> clearSelectedServer() async {
    try {
      await localStorage.clearSelectedServer();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to clear selected server: $e');
    }
  }

  @override
  Future<List<Server>> getFavoriteServers() async {
    try {
      final serverModels = await localStorage.getFavoriteServers();
      return serverModels.map((model) => model.toEntity()).toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get favorite servers: $e');
    }
  }

  @override
  Future<void> addToFavorites(Server server) async {
    try {
      final serverModel = ServerModel.fromEntity(server);
      await localStorage.addToFavorites(serverModel);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to add server to favorites: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(String serverId) async {
    try {
      await localStorage.removeFromFavorites(serverId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to remove server from favorites: $e');
    }
  }
}
