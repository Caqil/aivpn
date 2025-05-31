// States
import '../../../domain/entities/server.dart';
import 'package:equatable/equatable.dart';

abstract class ServerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServerInitial extends ServerState {}

class ServerLoading extends ServerState {}

class ServerLoaded extends ServerState {
  final List<Server> servers;
  final Server? selectedServer;
  final List<Server> favoriteServers;

  ServerLoaded({
    required this.servers,
    this.selectedServer,
    this.favoriteServers = const [],
  });

  ServerLoaded copyWith({
    List<Server>? servers,
    Server? selectedServer,
    List<Server>? favoriteServers,
    bool clearSelected = false,
  }) {
    return ServerLoaded(
      servers: servers ?? this.servers,
      selectedServer:
          clearSelected ? null : (selectedServer ?? this.selectedServer),
      favoriteServers: favoriteServers ?? this.favoriteServers,
    );
  }

  @override
  List<Object?> get props => [servers, selectedServer, favoriteServers];
}

class ServerError extends ServerState {
  final String message;
  ServerError(this.message);

  @override
  List<Object?> get props => [message];
}
