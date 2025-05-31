import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/vpn_state_model.dart';
import '../../../domain/entities/server.dart';
import '../../../domain/entities/vpn_connection.dart';
import '../../../domain/repositories/vpn_repository.dart';
import 'vpn_event.dart';
import 'vpn_state.dart';

// BLoC
class VpnBloc extends Bloc<VpnEvent, VpnState> {
  final VpnRepository repository;
  StreamSubscription<VpnConnection>? _connectionSubscription;

  VpnBloc(this.repository) : super(VpnInitial()) {
    on<ConnectToServer>(_onConnectToServer);
    on<DisconnectVpn>(_onDisconnectVpn);
    on<VpnConnectionChanged>(_onVpnConnectionChanged);
    on<CheckConnectionStatus>(_onCheckConnectionStatus);

    _subscribeToConnectionStream();
  }

  void _subscribeToConnectionStream() {
    _connectionSubscription = repository.connectionStream.listen(
      (connection) => add(VpnConnectionChanged(connection)),
    );
  }

  Future<void> _onConnectToServer(
      ConnectToServer event, Emitter<VpnState> emit) async {
    emit(VpnConnecting(event.server));
    try {
      await repository.connect(event.server);
    } catch (e) {
      emit(VpnError(e.toString()));
    }
  }

  Future<void> _onDisconnectVpn(
      DisconnectVpn event, Emitter<VpnState> emit) async {
    emit(VpnDisconnecting());
    try {
      await repository.disconnect();
    } catch (e) {
      emit(VpnError(e.toString()));
    }
  }

  Future<void> _onVpnConnectionChanged(
      VpnConnectionChanged event, Emitter<VpnState> emit) async {
    final connection = event.connection;

    switch (connection.status) {
      case VpnStatus.connected:
        emit(VpnConnected(connection));
        break;
      case VpnStatus.connecting:
        // Keep current connecting state if we have server info
        if (state is! VpnConnecting) {
          emit(VpnConnecting(Server(
            id: connection.serverId ?? '',
            name: connection.serverName ?? 'Unknown',
            country: connection.serverCountry ?? 'Unknown',
            address: '',
            port: 0,
            protocol: '',
          )));
        }
        break;
      case VpnStatus.disconnected:
        emit(VpnDisconnected());
        break;
      case VpnStatus.disconnecting:
        emit(VpnDisconnecting());
        break;
      case VpnStatus.error:
        emit(VpnError(connection.errorMessage ?? 'Unknown VPN error'));
        break;
    }
  }

  Future<void> _onCheckConnectionStatus(
      CheckConnectionStatus event, Emitter<VpnState> emit) async {
    try {
      final connection = await repository.getCurrentConnection();
      add(VpnConnectionChanged(connection));
    } catch (e) {
      emit(VpnError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    return super.close();
  }
}
