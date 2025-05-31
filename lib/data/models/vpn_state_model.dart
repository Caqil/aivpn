import 'package:equatable/equatable.dart';

enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnConnectionModel extends Equatable {
  final VpnStatus status;
  final String? serverId;
  final String? serverName;
  final String? serverCountry;
  final String? errorMessage;
  final DateTime? connectedAt;
  final Duration? connectionDuration;

  const VpnConnectionModel({
    this.status = VpnStatus.disconnected,
    this.serverId,
    this.serverName,
    this.serverCountry,
    this.errorMessage,
    this.connectedAt,
    this.connectionDuration,
  });

  VpnConnectionModel copyWith({
    VpnStatus? status,
    String? serverId,
    String? serverName,
    String? serverCountry,
    String? errorMessage,
    DateTime? connectedAt,
    Duration? connectionDuration,
  }) {
    return VpnConnectionModel(
      status: status ?? this.status,
      serverId: serverId ?? this.serverId,
      serverName: serverName ?? this.serverName,
      serverCountry: serverCountry ?? this.serverCountry,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedAt: connectedAt ?? this.connectedAt,
      connectionDuration: connectionDuration ?? this.connectionDuration,
    );
  }

  bool get isConnected => status == VpnStatus.connected;
  bool get isConnecting => status == VpnStatus.connecting;
  bool get isDisconnected => status == VpnStatus.disconnected;
  bool get isDisconnecting => status == VpnStatus.disconnecting;
  bool get hasError => status == VpnStatus.error;

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
