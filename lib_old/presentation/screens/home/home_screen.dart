import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_state.dart';
import '../../bloc/vpn/vpn_bloc.dart';
import '../../bloc/vpn/vpn_state.dart';
import '../../widgets/connection_button.dart';
import '../../widgets/status_indicator.dart';
import '../servers/server_list_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _navigateToServerList(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Status Section
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusIndicator(),
                      const SizedBox(height: 24),
                      _buildServerInfo(),
                    ],
                  ),
                ),
              ),

              // Connection Button
              Expanded(
                flex: 1,
                child: Center(
                  child: ConnectionButton(),
                ),
              ),

              // Server Selection
              _buildServerSelection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerInfo() {
    return BlocBuilder<ServerBloc, ServerState>(
      builder: (context, serverState) {
        return BlocBuilder<VpnBloc, VpnState>(
          builder: (context, vpnState) {
            if (vpnState is VpnConnected &&
                vpnState.connection.serverName != null) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Connected to',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vpnState.connection.serverName!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (vpnState.connection.serverCountry != null)
                        Text(
                          vpnState.connection.serverCountry!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              );
            }

            if (serverState is ServerLoaded &&
                serverState.selectedServer != null) {
              final server = serverState.selectedServer!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Selected Server',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        server.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        server.country,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No server selected',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServerSelection(BuildContext context) {
    return BlocBuilder<ServerBloc, ServerState>(
      builder: (context, state) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('Select Server'),
            subtitle: state is ServerLoaded && state.selectedServer != null
                ? Text(
                    '${state.selectedServer!.name} - ${state.selectedServer!.country}')
                : const Text('Tap to choose a server'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToServerList(context),
          ),
        );
      },
    );
  }

  void _navigateToServerList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServerListScreen(),
      ),
    );
  }
}
