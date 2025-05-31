import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/server.dart';
import '../../../domain/repositories/server_repository.dart';

// Events
abstract class ServerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadServers extends ServerEvent {}

class SelectServer extends ServerEvent {
  final Server server;
  SelectServer(this.server);

  @override
  List<Object?> get props => [server];
}

class ClearSelectedServer extends ServerEvent {}

class AddToFavorites extends ServerEvent {
  final Server server;
  AddToFavorites(this.server);

  @override
  List<Object?> get props => [server];
}

class RemoveFromFavorites extends ServerEvent {
  final String serverId;
  RemoveFromFavorites(this.serverId);

  @override
  List<Object?> get props => [serverId];
}

class LoadFavorites extends ServerEvent {}
