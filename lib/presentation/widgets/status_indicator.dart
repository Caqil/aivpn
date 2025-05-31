import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vpn/vpn_bloc.dart';
import '../bloc/vpn/vpn_state.dart';

class StatusIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VpnBloc, VpnState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildStatusIcon(state),
            const SizedBox(height: 16),
            _buildStatusText(context, state),
            if (state is VpnConnected && state.connection.connectedAt != null)
              _buildConnectionTime(context, state),
          ],
        );
      },
    );
  }

  Widget _buildStatusIcon(VpnState state) {
    Widget icon;
    Color color;

    if (state is VpnConnected) {
      icon = const Icon(Icons.shield, size: 80);
      color = Colors.green;
    } else if (state is VpnConnecting || state is VpnDisconnecting) {
      icon = TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 1),
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 2 * 3.14159,
            child: const Icon(Icons.sync, size: 80),
          );
        },
      );
      color = Colors.orange;
    } else if (state is VpnError) {
      icon = const Icon(Icons.error, size: 80);
      color = Colors.red;
    } else {
      icon = const Icon(Icons.shield_outlined, size: 80);
      color = Colors.grey;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(24),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(color: color),
        child: icon,
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, VpnState state) {
    String statusText;
    String? subtitleText;
    Color color;

    if (state is VpnConnected) {
      statusText = 'Connected';
      subtitleText = 'Your connection is secure';
      color = Colors.green;
    } else if (state is VpnConnecting) {
      statusText = 'Connecting...';
      subtitleText = 'Establishing secure connection';
      color = Colors.orange;
    } else if (state is VpnDisconnecting) {
      statusText = 'Disconnecting...';
      subtitleText = 'Closing connection';
      color = Colors.orange;
    } else if (state is VpnError) {
      statusText = 'Connection Failed';
      subtitleText = 'Tap to retry';
      color = Colors.red;
    } else {
      statusText = 'Disconnected';
      subtitleText = 'Your connection is not protected';
      color = Colors.grey;
    }

    return Column(
      children: [
        Text(
          statusText,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitleText != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitleText,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildConnectionTime(BuildContext context, VpnConnected state) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: StreamBuilder<int>(
        stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
        builder: (context, snapshot) {
          final connectedAt = state.connection.connectedAt!;
          final duration = DateTime.now().difference(connectedAt);

          return Text(
            'Connected for ${_formatDuration(duration)}',
            style: Theme.of(context).textTheme.bodySmall,
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
