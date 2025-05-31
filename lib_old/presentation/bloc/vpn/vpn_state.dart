import '../../../domain/entities/server.dart';
import '../../../domain/entities/vpn_connection.dart';
import 'package:equatable/equatable.dart';

abstract class VpnState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VpnInitial extends VpnState {}

class VpnConnecting extends VpnState {
  final Server server;
  VpnConnecting(this.server);

  @override
  List<Object?> get props => [server];
}

class VpnConnected extends VpnState {
  final VpnConnection connection;
  VpnConnected(this.connection);

  @override
  List<Object?> get props => [connection];
}

class VpnDisconnected extends VpnState {}

class VpnDisconnecting extends VpnState {}

class VpnError extends VpnState {
  final String message;
  VpnError(this.message);

  @override
  List<Object?> get props => [message];
}
