// lib/data/repositories/server_repository.dart - Updated to work with user profile servers
import '../../domain/entities/server.dart';
import '../../domain/repositories/server_repository.dart';
import '../datasources/server_api.dart';
import '../datasources/local_storage.dart';
import '../models/server_model.dart';
import '../../core/errors/exceptions.dart';

class ServerRepositoryImpl implements ServerRepository {
  final ServerApi serverApi;
  final LocalStorage localStorage;

  // Cache for servers loaded from user profile
  List<Server> _cachedServers = [];
  DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(hours: 1);

  ServerRepositoryImpl({required this.serverApi, required this.localStorage});

  @override
  Future<List<Server>> getServers() async {
    try {
      print('📡 Getting servers from repository...');

      // First, try to return cached servers if available and recent
      if (_cachedServers.isNotEmpty && _isCacheValid()) {
        print('✅ Returning ${_cachedServers.length} cached servers');
        return _cachedServers;
      }

      // If no cached servers, try to get from API (fallback)
      // Note: This is now a fallback since servers primarily come from user profile
      try {
        final serverModels = await serverApi.getServers();
        final servers = serverModels.map((model) => model.toEntity()).toList();

        if (servers.isNotEmpty) {
          _updateCache(servers);
          print('✅ Got ${servers.length} servers from API');
          return servers;
        }
      } catch (e) {
        print('⚠️ API servers unavailable: $e');
      }

      // If no servers from API and no cache, return empty list
      // Servers will be loaded from user profile via setServersFromUserProfile
      print('📝 No servers available, returning empty list');
      return [];
    } catch (e) {
      print('❌ Error getting servers: $e');
      // Return cached servers if available, even if expired
      if (_cachedServers.isNotEmpty) {
        print('⚠️ Returning expired cached servers due to error');
        return _cachedServers;
      }
      throw ServerException('Failed to get servers: $e');
    }
  }

  /// Update servers from user profile (this is the primary way servers are loaded)
  Future<void> setServersFromUserProfile(List<Server> servers) async {
    try {
      print('🔄 Setting ${servers.length} servers from user profile');
      _updateCache(servers);

      // Optionally save to local storage for offline access
      await _saveServersToLocalStorage(servers);

      print('✅ Successfully cached servers from user profile');
    } catch (e) {
      print('⚠️ Error setting servers from user profile: $e');
      // Don't throw error, just log it
    }
  }

  @override
  Future<void> saveSelectedServer(Server server) async {
    try {
      final serverModel = ServerModel.fromEntity(server);
      await localStorage.saveSelectedServer(serverModel);
      print('✅ Saved selected server: ${server.name}');
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
      final selectedServer = serverModel?.toEntity();

      if (selectedServer != null) {
        print('✅ Got selected server: ${selectedServer.name}');
      } else {
        print('📝 No selected server found');
      }

      return selectedServer;
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
      print('✅ Cleared selected server');
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
      final favorites = serverModels.map((model) => model.toEntity()).toList();
      print('✅ Got ${favorites.length} favorite servers');
      return favorites;
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
      print('✅ Added server to favorites: ${server.name}');
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
      print('✅ Removed server from favorites: $serverId');
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to remove server from favorites: $e');
    }
  }

  // Helper methods for caching
  void _updateCache(List<Server> servers) {
    _cachedServers = servers;
    _lastCacheTime = DateTime.now();
  }

  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    final now = DateTime.now();
    return now.difference(_lastCacheTime!) < _cacheTimeout;
  }

  // Save servers to local storage for offline access
  Future<void> _saveServersToLocalStorage(List<Server> servers) async {
    try {
      // This could be implemented to save servers locally
      // For now, we'll just log it
      print('💾 Saving ${servers.length} servers to local storage');
    } catch (e) {
      print('⚠️ Failed to save servers to local storage: $e');
    }
  }

  // Get servers from local storage (offline fallback)
  Future<List<Server>> _getServersFromLocalStorage() async {
    try {
      // This could be implemented to load servers from local storage
      // For now, return empty list
      print('📱 Attempting to load servers from local storage');
      return [];
    } catch (e) {
      print('⚠️ Failed to load servers from local storage: $e');
      return [];
    }
  }

  // Public method to check if servers are cached
  bool hasServers() {
    return _cachedServers.isNotEmpty;
  }

  // Public method to get cached server count
  int getCachedServerCount() {
    return _cachedServers.length;
  }

  // Public method to refresh cache
  Future<void> refreshServers() async {
    _cachedServers.clear();
    _lastCacheTime = null;
    await getServers();
  }
}
