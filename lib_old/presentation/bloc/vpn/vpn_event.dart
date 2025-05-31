import 'package:equatable/equatable.dart';

import '../../../domain/entities/server.dart';
import '../../../domain/entities/vpn_connection.dart';

abstract class VpnEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectToServer extends VpnEvent {
  final Server server;
  ConnectToServer(this.server);

  @override
  List<Object?> get props => [server];
}

class DisconnectVpn extends VpnEvent {}

class VpnConnectionChanged extends VpnEvent {
  final VpnConnection connection;
  VpnConnectionChanged(this.connection);

  @override
  List<Object?> get props => [connection];
}

class CheckConnectionStatus extends VpnEvent {}
