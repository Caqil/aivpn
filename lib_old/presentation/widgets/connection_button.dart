import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/server/server_bloc.dart';
import '../bloc/server/server_state.dart';
import '../bloc/vpn/vpn_bloc.dart';
import '../bloc/vpn/vpn_event.dart';
import '../bloc/vpn/vpn_state.dart';

class ConnectionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VpnBloc, VpnState>(
      builder: (context, vpnState) {
        return BlocBuilder<ServerBloc, ServerState>(
          builder: (context, serverState) {
            return Container(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  // Outer ring animation for connecting state
                  if (vpnState is VpnConnecting || vpnState is VpnDisconnecting)
                    Positioned.fill(
                      child: _buildAnimatedRing(),
                    ),

                  // Main button
                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          _handleButtonPress(context, vpnState, serverState),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _getButtonGradient(vpnState),
                          boxShadow: [
                            BoxShadow(
                              color: _getButtonColor(vpnState).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getButtonIcon(vpnState),
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getButtonText(vpnState),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedRing() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleButtonPress(
      BuildContext context, VpnState vpnState, ServerState serverState) {
    if (vpnState is VpnConnecting || vpnState is VpnDisconnecting) {
      return; // Ignore taps during transitions
    }

    if (vpnState is VpnConnected) {
      // Disconnect
      context.read<VpnBloc>().add(DisconnectVpn());
    } else {
      // Connect
      if (serverState is ServerLoaded && serverState.selectedServer != null) {
        context
            .read<VpnBloc>()
            .add(ConnectToServer(serverState.selectedServer!));
      } else {
        _showNoServerSelectedDialog(context);
      }
    }
  }

  void _showNoServerSelectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Server Selected'),
        content: const Text('Please select a server before connecting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  LinearGradient _getButtonGradient(VpnState state) {
    Color primaryColor = _getButtonColor(state);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        primaryColor.withOpacity(0.8),
      ],
    );
  }

  Color _getButtonColor(VpnState state) {
    if (state is VpnConnected) {
      return Colors.green;
    } else if (state is VpnConnecting || state is VpnDisconnecting) {
      return Colors.orange;
    } else if (state is VpnError) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  IconData _getButtonIcon(VpnState state) {
    if (state is VpnConnected) {
      return Icons.vpn_key;
    } else if (state is VpnConnecting || state is VpnDisconnecting) {
      return Icons.sync;
    } else if (state is VpnError) {
      return Icons.error;
    } else {
      return Icons.vpn_key_off;
    }
  }

  String _getButtonText(VpnState state) {
    if (state is VpnConnected) {
      return 'DISCONNECT';
    } else if (state is VpnConnecting) {
      return 'CONNECTING...';
    } else if (state is VpnDisconnecting) {
      return 'DISCONNECTING...';
    } else if (state is VpnError) {
      return 'ERROR\nTAP TO RETRY';
    } else {
      return 'CONNECT';
    }
  }
}
