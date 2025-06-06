import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:load_switch/load_switch.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_state.dart';
import '../../bloc/vpn/vpn_bloc.dart';
import '../../bloc/vpn/vpn_state.dart';
import '../../bloc/vpn/vpn_event.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../widgets/globe_widget.dart';
import '../servers/server_list_screen.dart';
import '../settings/settings_screen.dart';
import '../subscription/subscription_screen.dart';
import '../../../core/services/admob_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // AdMobService.createInterstitialAd();
    // AdMobService.createRewardedAd();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.resumed) {
    //   AdMobService.showAppOpenAdIfAvailable();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Globe Background
          const GlobeWidget(),

          // Bottom Control Panel
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
              child: Transform.scale(
                scale: 0.5,
                child: Image.asset(
                  'assets/icons/diamond.png',
                  height: 15,
                  width: 15,
                ),
              ),
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
      padding: const EdgeInsets.all(20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: const BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: BlocBuilder<ServerBloc, ServerState>(
          builder: (context, serverState) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildServerInfo(serverState),
                _buildConnectionSwitch(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildServerInfo(ServerState serverState) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => ServerListScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCountryFlag(serverState),
            const SizedBox(width: 5),
            _buildServerDetails(serverState),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryFlag(ServerState serverState) {
    if (serverState is ServerLoaded && serverState.selectedServer != null) {
      final countryCode = serverState.selectedServer!.country.toLowerCase();
      return Image.asset(
        'assets/icons/flags/$countryCode.png',
        width: 30,
        height: 20,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 30,
            height: 20,
            color: Colors.grey,
            child: const Icon(Icons.flag, size: 16),
          );
        },
      );
    }

    return Container(
      width: 30,
      height: 20,
      color: Colors.grey,
      child: const Icon(Icons.flag, size: 16, color: Colors.white),
    );
  }

  Widget _buildServerDetails(ServerState serverState) {
    if (serverState is ServerLoaded && serverState.selectedServer != null) {
      final server = serverState.selectedServer!;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${server.country}, ${server.address}",
            style: const TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 150.w,
            child: Text(
              server.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Platform.isMacOS ? 9.sp : 10.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("No Server Selected", style: TextStyle(color: Colors.white)),
        Text(
          "Tap to select",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Platform.isMacOS ? 9.sp : 10.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionSwitch() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Center(
        child: BlocBuilder<VpnBloc, VpnState>(
          builder: (context, vpnState) {
            return BlocBuilder<ServerBloc, ServerState>(
              builder: (context, serverState) {
                return BlocBuilder<UserBloc, UserState>(
                  builder: (context, userState) {
                    return LoadSwitch(
                      curveIn: Curves.easeInBack,
                      curveOut: Curves.easeOutBack,
                      thumbDecoration: (value, isActive) {
                        return BoxDecoration(
                          color: value
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.darkBackgroundGray,
                          borderRadius: BorderRadius.circular(30),
                          shape: BoxShape.rectangle,
                          boxShadow: [
                            BoxShadow(
                              color: value
                                  ? CupertinoColors.activeGreen.withOpacity(0.2)
                                  : CupertinoColors.systemRed.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        );
                      },
                      height: 25.h,
                      width: Platform.isMacOS ? 35.sp : 40.w,
                      value: vpnState is VpnConnected,
                      future: () => _getFuture(vpnState),
                      style: SpinStyle.threeInOut,
                      spinColor: (value) => value
                          ? const Color.fromARGB(255, 41, 232, 31)
                          : const Color.fromARGB(255, 255, 77, 77),
                      spinStrokeWidth: 3,
                      onChange: (bool value) => _handleConnectionToggle(
                        context,
                        vpnState,
                        serverState,
                        userState,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
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

                // Show ads for free users
                if (userState is UserLoaded && !userState.user.isPremium) {
                  // Future.delayed(Duration.zero, () {
                  //   AdMobService.showInterstitialAd();
                  // });
                }
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

      // Show ads for free users
      if (userState is UserLoaded && !userState.user.isPremium) {
        // Future.delayed(const Duration(seconds: 2), () {
        //   AdMobService.showRewardedAd();
        // });
      }
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
