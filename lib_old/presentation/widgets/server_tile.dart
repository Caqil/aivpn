import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/server.dart';
import '../bloc/server/server_bloc.dart';
import '../bloc/server/server_state.dart';

class ServerTile extends StatelessWidget {
  final Server server;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const ServerTile({
    Key? key,
    required this.server,
    this.isSelected = false,
    this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerBloc, ServerState>(
      builder: (context, state) {
        final isFavorite = state is ServerLoaded &&
            state.favoriteServers.any((s) => s.id == server.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: _buildLeading(),
            title: Text(
              server.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(server.connectionString),
                Row(
                  children: [
                    _buildProtocolChip(),
                    const SizedBox(width: 8),
                    if (server.isPremium) _buildPremiumChip(),
                    if (server.ping > 0) _buildPingChip(),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: onFavoriteToggle,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                else
                  const Icon(Icons.radio_button_unchecked),
              ],
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }

  Widget _buildLeading() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          server.country.isNotEmpty
              ? server.country.substring(0, 2).toUpperCase()
              : 'UN',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildProtocolChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        server.protocol.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildPremiumChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'PREMIUM',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildPingChip() {
    Color pingColor;
    if (server.ping < 50) {
      pingColor = Colors.green;
    } else if (server.ping < 100) {
      pingColor = Colors.orange;
    } else {
      pingColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: pingColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${server.ping}ms',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: pingColor,
        ),
      ),
    );
  }
}
