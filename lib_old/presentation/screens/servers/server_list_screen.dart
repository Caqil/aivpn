import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_event.dart';
import '../../bloc/server/server_state.dart';
import '../../widgets/server_tile.dart';
import '../../../domain/entities/server.dart';

class ServerListScreen extends StatefulWidget {
  @override
  _ServerListScreenState createState() => _ServerListScreenState();
}

class _ServerListScreenState extends State<ServerListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ServerBloc>().add(LoadServers());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Servers'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: BlocBuilder<ServerBloc, ServerState>(
        builder: (context, state) {
          if (state is ServerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading servers',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ServerBloc>().add(LoadServers());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ServerLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildServerList(state.servers, state.selectedServer),
                _buildFavoritesList(
                    state.favoriteServers, state.selectedServer),
              ],
            );
          }

          return const Center(child: Text('No servers available'));
        },
      ),
    );
  }

  Widget _buildServerList(List<Server> servers, Server? selectedServer) {
    if (servers.isEmpty) {
      return const Center(
        child: Text('No servers available'),
      );
    }

    // Group servers by country
    final groupedServers = <String, List<Server>>{};
    for (final server in servers) {
      groupedServers.putIfAbsent(server.country, () => []).add(server);
    }

    return ListView.builder(
      itemCount: groupedServers.length,
      itemBuilder: (context, index) {
        final country = groupedServers.keys.elementAt(index);
        final countryServers = groupedServers[country]!;

        return ExpansionTile(
          title: Text(
            '$country (${countryServers.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          children: countryServers.map((server) {
            return ServerTile(
              server: server,
              isSelected: selectedServer?.id == server.id,
              onTap: () => _selectServer(context, server),
              onFavoriteToggle: () => _toggleFavorite(context, server),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFavoritesList(List<Server> favorites, Server? selectedServer) {
    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No favorite servers'),
            SizedBox(height: 8),
            Text('Tap the heart icon on any server to add it to favorites'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final server = favorites[index];
        return ServerTile(
          server: server,
          isSelected: selectedServer?.id == server.id,
          onTap: () => _selectServer(context, server),
          onFavoriteToggle: () => _toggleFavorite(context, server),
        );
      },
    );
  }

  void _selectServer(BuildContext context, Server server) {
    context.read<ServerBloc>().add(SelectServer(server));
    Navigator.of(context).pop();
  }

  void _toggleFavorite(BuildContext context, Server server) {
    final serverBloc = context.read<ServerBloc>();
    final state = serverBloc.state;

    if (state is ServerLoaded) {
      final isFavorite = state.favoriteServers.any((s) => s.id == server.id);
      if (isFavorite) {
        serverBloc.add(RemoveFromFavorites(server.id));
      } else {
        serverBloc.add(AddToFavorites(server));
      }
    }
  }
}
