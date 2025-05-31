import 'package:equatable/equatable.dart';
import '../../data/models/vpn_state_model.dart';

class VpnConnection extends Equatable {
  final VpnStatus status;
  final String? serverId;
  final String? serverName;
  final String? serverCountry;
  final String? errorMessage;
  final DateTime? connectedAt;
  final Duration? connectionDuration;

  const VpnConnection({
    this.status = VpnStatus.disconnected,
    this.serverId,
    this.serverName,
    this.serverCountry,
    this.errorMessage,
    this.connectedAt,
    this.connectionDuration,
  });

  bool get isConnected => status == VpnStatus.connected;
  bool get isConnecting => status == VpnStatus.connecting;
  bool get isDisconnected => status == VpnStatus.disconnected;
  bool get isDisconnecting => status == VpnStatus.disconnecting;
  bool get hasError => status == VpnStatus.error;

  String get statusText {
    switch (status) {
      case VpnStatus.connected:
        return 'Connected';
      case VpnStatus.connecting:
        return 'Connecting...';
      case VpnStatus.disconnected:
        return 'Disconnected';
      case VpnStatus.disconnecting:
        return 'Disconnecting...';
      case VpnStatus.error:
        return 'Error';
    }
  }

  @override
  List<Object?> get props => [
        status,
        serverId,
        serverName,
        serverCountry,
        errorMessage,
        connectedAt,
        connectionDuration,
      ];
}
