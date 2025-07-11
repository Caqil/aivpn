// lib/presentation/bloc/server/server_bloc.dart - Updated to handle user profile servers
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/server.dart';
import '../../../domain/repositories/server_repository.dart';
import '../../../data/repositories/server_repository.dart' as impl;
import 'server_event.dart';
import 'server_state.dart';

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  final ServerRepository repository;

  ServerBloc(this.repository) : super(ServerInitial()) {
    on<LoadServers>(_onLoadServers);
    on<LoadServersFromProfile>(_onLoadServersFromProfile);
    on<SelectServer>(_onSelectServer);
    on<ClearSelectedServer>(_onClearSelectedServer);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<LoadFavorites>(_onLoadFavorites);
    on<RefreshServers>(_onRefreshServers);
  }

  Future<void> _onLoadServers(
    LoadServers event,
    Emitter<ServerState> emit,
  ) async {
    emit(ServerLoading());
    try {
      print('🔄 Loading servers from repository...');

      final servers = await repository.getServers();
      final selectedServer = await repository.getSelectedServer();
      final favoriteServers = await repository.getFavoriteServers();

      print(
        '✅ Loaded ${servers.length} servers, selected: ${selectedServer?.name ?? 'none'}',
      );

      emit(
        ServerLoaded(
          servers: servers,
          selectedServer: selectedServer,
          favoriteServers: favoriteServers,
        ),
      );
    } catch (e) {
      print('❌ Failed to load servers: $e');
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onLoadServersFromProfile(
    LoadServersFromProfile event,
    Emitter<ServerState> emit,
  ) async {
    try {
      print('🔄 Loading ${event.servers.length} servers from user profile...');

      // Set servers in repository cache
      if (repository is impl.ServerRepositoryImpl) {
        await (repository as impl.ServerRepositoryImpl)
            .setServersFromUserProfile(event.servers);
      }

      // Load other data
      final selectedServer = await repository.getSelectedServer();
      final favoriteServers = await repository.getFavoriteServers();

      // If no server is selected and we have servers, select the first one
      Server? finalSelectedServer = selectedServer;
      if (finalSelectedServer == null && event.servers.isNotEmpty) {
        finalSelectedServer = event.servers.first;
        await repository.saveSelectedServer(finalSelectedServer);
        print('✅ Auto-selected first server: ${finalSelectedServer.name}');
      }

      print('✅ Successfully loaded servers from profile');

      emit(
        ServerLoaded(
          servers: event.servers,
          selectedServer: finalSelectedServer,
          favoriteServers: favoriteServers,
        ),
      );
    } catch (e) {
      print('❌ Failed to load servers from profile: $e');

      // Try to fall back to regular server loading
      add(LoadServers());
    }
  }

  Future<void> _onSelectServer(
    SelectServer event,
    Emitter<ServerState> emit,
  ) async {
    try {
      print('🎯 Selecting server: ${event.server.name}');
      await repository.saveSelectedServer(event.server);

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        emit(currentState.copyWith(selectedServer: event.server));
        print('✅ Server selected successfully');
      }
    } catch (e) {
      print('❌ Failed to select server: $e');
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onClearSelectedServer(
    ClearSelectedServer event,
    Emitter<ServerState> emit,
  ) async {
    try {
      await repository.clearSelectedServer();

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        emit(currentState.copyWith(clearSelected: true));
        print('✅ Cleared selected server');
      }
    } catch (e) {
      print('❌ Failed to clear selected server: $e');
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<ServerState> emit,
  ) async {
    try {
      await repository.addToFavorites(event.server);

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        final updatedFavorites = List<Server>.from(
          currentState.favoriteServers,
        );

        // Check if server is already in favorites
        if (!updatedFavorites.any((s) => s.id == event.server.id)) {
          updatedFavorites.add(event.server);
          emit(currentState.copyWith(favoriteServers: updatedFavorites));
          print('✅ Added server to favorites: ${event.server.name}');
        }
      }
    } catch (e) {
      print('❌ Failed to add server to favorites: $e');
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<ServerState> emit,
  ) async {
    try {
      await repository.removeFromFavorites(event.serverId);

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        final updatedFavorites = currentState.favoriteServers
            .where((s) => s.id != event.serverId)
            .toList();
        emit(currentState.copyWith(favoriteServers: updatedFavorites));
        print('✅ Removed server from favorites: ${event.serverId}');
      }
    } catch (e) {
      print('❌ Failed to remove server from favorites: $e');
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<ServerState> emit,
  ) async {
    try {
      final favoriteServers = await repository.getFavoriteServers();

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        emit(currentState.copyWith(favoriteServers: favoriteServers));
        print('✅ Reloaded ${favoriteServers.length} favorite servers');
      }
    } catch (e) {
      print('❌ Failed to load favorites: $e');
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onRefreshServers(
    RefreshServers event,
    Emitter<ServerState> emit,
  ) async {
    print('🔄 Refreshing servers...');

    // Clear cache if available
    if (repository is impl.ServerRepositoryImpl) {
      await (repository as impl.ServerRepositoryImpl).refreshServers();
    }

    // Reload servers
    add(LoadServers());
  }

  // Helper method to get current servers
  List<Server> getCurrentServers() {
    if (state is ServerLoaded) {
      return (state as ServerLoaded).servers;
    }
    return [];
  }

  // Helper method to get selected server
  Server? getSelectedServer() {
    if (state is ServerLoaded) {
      return (state as ServerLoaded).selectedServer;
    }
    return null;
  }

  // Helper method to check if servers are loaded
  bool hasServers() {
    return state is ServerLoaded && (state as ServerLoaded).servers.isNotEmpty;
  }

  // Helper method to get server count
  int getServerCount() {
    if (state is ServerLoaded) {
      return (state as ServerLoaded).servers.length;
    }
    return 0;
  }

  // Helper method to find server by ID
  Server? findServerById(String serverId) {
    if (state is ServerLoaded) {
      final servers = (state as ServerLoaded).servers;
      try {
        return servers.firstWhere((server) => server.id == serverId);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
