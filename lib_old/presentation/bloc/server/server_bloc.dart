// BLoC
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/server.dart';
import '../../../domain/repositories/server_repository.dart';
import 'server_event.dart';
import 'server_state.dart';

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  final ServerRepository repository;

  ServerBloc(this.repository) : super(ServerInitial()) {
    on<LoadServers>(_onLoadServers);
    on<SelectServer>(_onSelectServer);
    on<ClearSelectedServer>(_onClearSelectedServer);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<LoadFavorites>(_onLoadFavorites);
  }

  Future<void> _onLoadServers(
      LoadServers event, Emitter<ServerState> emit) async {
    emit(ServerLoading());
    try {
      final servers = await repository.getServers();
      final selectedServer = await repository.getSelectedServer();
      final favoriteServers = await repository.getFavoriteServers();

      emit(ServerLoaded(
        servers: servers,
        selectedServer: selectedServer,
        favoriteServers: favoriteServers,
      ));
    } catch (e) {
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onSelectServer(
      SelectServer event, Emitter<ServerState> emit) async {
    try {
      await repository.saveSelectedServer(event.server);

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        emit(currentState.copyWith(selectedServer: event.server));
      }
    } catch (e) {
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onClearSelectedServer(
      ClearSelectedServer event, Emitter<ServerState> emit) async {
    try {
      await repository.clearSelectedServer();

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        emit(currentState.copyWith(clearSelected: true));
      }
    } catch (e) {
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
      AddToFavorites event, Emitter<ServerState> emit) async {
    try {
      await repository.addToFavorites(event.server);

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        final updatedFavorites =
            List<Server>.from(currentState.favoriteServers);
        if (!updatedFavorites.any((s) => s.id == event.server.id)) {
          updatedFavorites.add(event.server);
        }
        emit(currentState.copyWith(favoriteServers: updatedFavorites));
      }
    } catch (e) {
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
      RemoveFromFavorites event, Emitter<ServerState> emit) async {
    try {
      await repository.removeFromFavorites(event.serverId);

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        final updatedFavorites = currentState.favoriteServers
            .where((s) => s.id != event.serverId)
            .toList();
        emit(currentState.copyWith(favoriteServers: updatedFavorites));
      }
    } catch (e) {
      emit(ServerError(e.toString()));
    }
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event, Emitter<ServerState> emit) async {
    try {
      final favoriteServers = await repository.getFavoriteServers();

      if (state is ServerLoaded) {
        final currentState = state as ServerLoaded;
        emit(currentState.copyWith(favoriteServers: favoriteServers));
      }
    } catch (e) {
      emit(ServerError(e.toString()));
    }
  }
}
