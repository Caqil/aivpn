import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/location_service.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_state.dart';
import '../../bloc/vpn/vpn_bloc.dart';
import '../../bloc/vpn/vpn_state.dart';
import '../../bloc/vpn/vpn_event.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../widgets/globe_widget.dart';
import '../connection/debug.dart';
import '../servers/server_list_screen.dart';
import '../settings/settings_screen.dart';
import '../subscription/subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _preloadUserLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _preloadUserLocation() async {
    try {
      // This will cache the user's location for the GlobeWidget
      await LocationService.instance.getCurrentLocation();
      print('User location preloaded successfully');
    } catch (e) {
      print('Failed to preload user location: $e');
      // Don't show error to user, GlobeWidget will handle fallback
    }
  }

  // Optional: Add a method to refresh location
  Future<void> _refreshLocation() async {
    try {
      LocationService.instance.clearCache();
      await LocationService.instance.getCurrentLocation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update location: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Globe Background (Handle globe widget gracefully)
          Center(child: const GlobeWidget()),

          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: SingleChildScrollView(child: const TargetedVpnDebugWidget()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomControlPanel(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: BlocBuilder<VpnBloc, VpnState>(
        builder: (context, vpnState) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: vpnState is VpnConnected
                ? RichText(
                    key: const ValueKey(0),
                    text: const TextSpan(
                      text: 'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Connected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                      ],
                    ),
                  )
                : RichText(
                    key: const ValueKey(1),
                    text: const TextSpan(
                      text: 'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Disconnected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemRed,
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
      leading: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoaded && !userState.user.isPremium) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              child: const Icon(Icons.diamond, color: Colors.amber),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          icon: const Icon(CupertinoIcons.settings),
        ),
      ],
    );
  }

  Widget _buildBottomControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.08,
          maxHeight: MediaQuery.of(context).size.height * 0.12,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BlocBuilder<ServerBloc, ServerState>(
          builder: (context, serverState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _buildServerInfo(serverState)),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  SizedBox(width: 80, child: _buildConnectionSwitch()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 2. Replace your _buildServerInfo method
  Widget _buildServerInfo(ServerState serverState) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => ServerListScreen()),
        );
      },
      child: Row(
        children: [
          _buildCountryFlag(serverState),
          const SizedBox(width: 12),
          Expanded(child: _buildServerDetails(serverState)),
        ],
      ),
    );
  }

  Widget _buildCountryFlag(ServerState serverState) {
    if (serverState is ServerLoaded && serverState.selectedServer != null) {
      final server = serverState.selectedServer!;
      final flagPath = _getFlagAssetPath(server.country);

      return Container(
        width: 36,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            flagPath.toLowerCase(),
            width: 36,
            height: 24,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Default state - no server selected
    return Container(
      width: 36,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
      ),
      child: const Icon(Icons.public, size: 16, color: Colors.white60),
    );
  }

  // Helper method to get flag asset path
  String _getFlagAssetPath(String country) {
    return 'assets/flags/$country.png';
  }

  // 4. Replace your _buildServerDetails method
  Widget _buildServerDetails(ServerState serverState) {
    if (serverState is ServerLoaded && serverState.selectedServer != null) {
      final server = serverState.selectedServer!;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.green.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  server.country,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          BlocBuilder<VpnBloc, VpnState>(
            builder: (context, vpnState) {
              return Row(
                children: [
                  _buildStatusDot(vpnState is VpnConnected),
                  const SizedBox(width: 4),
                  Text(
                    vpnState is VpnConnected ? 'Connected' : 'Ready',
                    style: TextStyle(
                      color: vpnState is VpnConnected
                          ? Colors.green.withOpacity(0.8)
                          : Colors.orange.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.touch_app,
              size: 14,
              color: Colors.grey.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            const Text(
              "Select Server",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          "Tap to choose location",
          style: TextStyle(
            color: Colors.grey.withOpacity(0.7),
            fontSize: Platform.isMacOS ? 10 : 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildStatusDot(false),
            const SizedBox(width: 4),
            Text(
              'Not Selected',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 5. Add this new helper method
  Widget _buildStatusDot(bool isConnected) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.green.withOpacity(0.8)
            : Colors.grey.withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: isConnected
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  // 6. Replace your _buildConnectionSwitch method
  Widget _buildConnectionSwitch() {
    return Center(
      child: BlocBuilder<VpnBloc, VpnState>(
        builder: (context, vpnState) {
          return BlocBuilder<ServerBloc, ServerState>(
            builder: (context, serverState) {
              return BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  final isConnected = vpnState is VpnConnected;
                  final isLoading =
                      vpnState is VpnConnecting || vpnState is VpnDisconnecting;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => _handleConnectionToggle(
                                context,
                                vpnState,
                                serverState,
                                userState,
                              ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 54,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: isConnected
                                  ? [
                                      Colors.green.withOpacity(0.8),
                                      Colors.green,
                                    ]
                                  : [
                                      Colors.grey.withOpacity(0.6),
                                      Colors.grey.withOpacity(0.8),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isConnected
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment: isConnected
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: isLoading
                                      ? const Center(
                                          child: SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    CupertinoColors.systemBlue,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          isConnected
                                              ? Icons.vpn_key
                                              : Icons.vpn_key_off,
                                          size: 14,
                                          color: isConnected
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isLoading
                            ? (vpnState is VpnConnecting
                                  ? 'Connecting...'
                                  : 'Disconnecting...')
                            : (isConnected ? 'ON' : 'OFF'),
                        style: TextStyle(
                          color: isConnected
                              ? Colors.green.withOpacity(0.9)
                              : Colors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _getFuture(VpnState vpnState) async {
    await Future.delayed(const Duration(seconds: 2));
    return vpnState is VpnConnected;
  }

  void _handleConnectionToggle(
    BuildContext context,
    VpnState vpnState,
    ServerState serverState,
    UserState userState,
  ) {
    if (vpnState is VpnConnected) {
      _showDisconnectDialog(context, userState);
    } else {
      _connectToVpn(context, serverState, userState);
    }
  }

  void _showDisconnectDialog(BuildContext context, UserState userState) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Disconnect"),
          content: const Text("Are you sure you want to disconnect from VPN?"),
          actions: <Widget>[
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<VpnBloc>().add(DisconnectVpn());
              },
              child: const Text(
                'Disconnect',
                style: TextStyle(color: CupertinoColors.systemRed),
              ),
            ),
            CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _connectToVpn(
    BuildContext context,
    ServerState serverState,
    UserState userState,
  ) {
    if (serverState is ServerLoaded && serverState.selectedServer != null) {
      context.read<VpnBloc>().add(ConnectToServer(serverState.selectedServer!));
    } else {
      _showNoServerSelectedDialog(context);
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => ServerListScreen()),
              );
            },
            child: const Text('Select Server'),
          ),
        ],
      ),
    );
  }
}
