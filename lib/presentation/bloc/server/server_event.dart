// lib/presentation/bloc/server/server_event.dart - Updated with new events
import 'package:equatable/equatable.dart';
import '../../../domain/entities/server.dart';

// Events
abstract class ServerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadServers extends ServerEvent {}

class LoadServersFromProfile extends ServerEvent {
  final List<Server> servers;

  LoadServersFromProfile(this.servers);

  @override
  List<Object?> get props => [servers];
}

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

class RefreshServers extends ServerEvent {}

// New events for better server management
class UpdateServerPing extends ServerEvent {
  final String serverId;
  final int ping;

  UpdateServerPing(this.serverId, this.ping);

  @override
  List<Object?> get props => [serverId, ping];
}

class FilterServers extends ServerEvent {
  final String? countryFilter;
  final String? protocolFilter;
  final bool? isPremiumFilter;
  final String? searchQuery;

  FilterServers({
    this.countryFilter,
    this.protocolFilter,
    this.isPremiumFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
    countryFilter,
    protocolFilter,
    isPremiumFilter,
    searchQuery,
  ];
}
