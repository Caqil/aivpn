import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server_model.dart';
import '../../core/errors/exceptions.dart';

abstract class LocalStorage {
  Future<void> saveSelectedServer(ServerModel server);
  Future<ServerModel?> getSelectedServer();
  Future<void> clearSelectedServer();
  Future<List<ServerModel>> getFavoriteServers();
  Future<void> addToFavorites(ServerModel server);
  Future<void> removeFromFavorites(String serverId);
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences sharedPreferences;

  LocalStorageImpl(this.sharedPreferences);

  static const String _selectedServerKey = 'selected_server';
  static const String _favoriteServersKey = 'favorite_servers';

  @override
  Future<void> saveSelectedServer(ServerModel server) async {
    try {
      final serverJson = json.encode(server.toJson());
      await sharedPreferences.setString(_selectedServerKey, serverJson);
    } catch (e) {
      throw CacheException('Failed to save selected server: $e');
    }
  }

  @override
  Future<ServerModel?> getSelectedServer() async {
    try {
      final serverJson = sharedPreferences.getString(_selectedServerKey);
      if (serverJson != null) {
        final serverMap = json.decode(serverJson);
        return ServerModel.fromJson(serverMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get selected server: $e');
    }
  }

  @override
  Future<void> clearSelectedServer() async {
    try {
      await sharedPreferences.remove(_selectedServerKey);
    } catch (e) {
      throw CacheException('Failed to clear selected server: $e');
    }
  }

  @override
  Future<List<ServerModel>> getFavoriteServers() async {
    try {
      final favoriteServersJson =
          sharedPreferences.getStringList(_favoriteServersKey);
      if (favoriteServersJson != null) {
        return favoriteServersJson
            .map((serverJson) => ServerModel.fromJson(json.decode(serverJson)))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to get favorite servers: $e');
    }
  }

  @override
  Future<void> addToFavorites(ServerModel server) async {
    try {
      final favorites = await getFavoriteServers();
      final existingIndex = favorites.indexWhere((s) => s.id == server.id);

      if (existingIndex == -1) {
        favorites.add(server);
        final favoriteServersJson =
            favorites.map((server) => json.encode(server.toJson())).toList();
        await sharedPreferences.setStringList(
            _favoriteServersKey, favoriteServersJson);
      }
    } catch (e) {
      throw CacheException('Failed to add server to favorites: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(String serverId) async {
    try {
      final favorites = await getFavoriteServers();
      favorites.removeWhere((server) => server.id == serverId);

      final favoriteServersJson =
          favorites.map((server) => json.encode(server.toJson())).toList();
      await sharedPreferences.setStringList(
          _favoriteServersKey, favoriteServersJson);
    } catch (e) {
      throw CacheException('Failed to remove server from favorites: $e');
    }
  }
}
