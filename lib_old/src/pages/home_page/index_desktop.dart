import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:flutter_earth_globe/point_connection_style.dart';
import 'package:flutter_earth_globe/sphere_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:load_switch/load_switch.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/server/server_screen.dart';
import 'package:safer_vpn/src/pages/setting/setting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/infrastructure/server/ovpn.dart';

class HomePageDesk extends StatefulWidget {
  final User user;
  const HomePageDesk({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageDeskState createState() => _HomePageDeskState();
}

class _HomePageDeskState extends State<HomePageDesk>
    with TickerProviderStateMixin, WindowListener {
  late StreamSubscription stageStream;
  late List<Point> points;
  late FlutterEarthGlobeController _controller;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  List<PointConnection> connections = [];
  bool showProgress = false;

  Widget pointLabelBuilder(
      BuildContext context, Point point, bool isHovering, bool visible) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: isHovering
              ? CupertinoColors.systemRed.withOpacity(0.8)
              : CupertinoColors.systemRed.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: CupertinoColors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2)
          ]),
      child: Text(point.label ?? '',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: CupertinoColors.white,
              )),
    );
  }

  Widget connectionLabelBuilder(BuildContext context,
      PointConnection connection, bool isHovering, bool visible) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: isHovering
              ? CupertinoColors.systemBlue.withOpacity(0.8)
              : CupertinoColors.systemBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: CupertinoColors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2)
          ]),
      child: Text(
        connection.label ?? '',
        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              color: CupertinoColors.white,
            ),
      ),
    );
  }

  @override
  void initState() {
    _controller = FlutterEarthGlobeController(
        maxZoom: 0.5,
        sphereStyle: const SphereStyle(
            shadowColor: CupertinoColors.systemCyan, shadowBlurSigma: 30),
        rotationSpeed: 0.05,
        zoom: 0.5,
        minZoom: 0.48,
        isRotating: false,
        isBackgroundFollowingSphereRotation: true,
        background: Image.asset('assets/2k_stars.jpg').image,
        surface: Image.asset('assets/day.jpg').image);
    _scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
    windowManager.addListener(this);
    _init();
    stageStream = OVPN.vpnStageSnapshot().listen((statusVpn) async {
      switch (statusVpn) {
        case OVPN.vpnConnected:
          setState(() {
            showProgress = false;
          });
          break;
        case OVPN.vpnDisconnected:
          setState(() {
            showProgress = false;
          });
          break;
        default:
          setState(() {
            showProgress = true;
          });
          break;
      }
      ServersNotifier.getStateVPN(context, statusVpn);
    });
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure you want to close this window?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _init() async {
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  void checkBannedUser() async {
    if (widget.user.status == 0) {
      Future.delayed(Duration.zero, () {
        showCupertinoDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text("Suspended Account"),
              content: const Text(
                  'Your account has been suspended, please contact us'),
              actions: <Widget>[
                GestureDetector(
                    onTap: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: contactEmail,
                        query: encodeQueryParameters(<String, String>{
                          'Contact': 'Suspended Account',
                        }),
                      );
                      if (!await launchUrl(emailLaunchUri)) {
                        throw 'Could not launch $emailLaunchUri';
                      }
                    },
                    child: const Text('Contact Us')),
              ],
            );
          },
        );
      });
    } else {
      null;
    }
  }

  @override
  void dispose() {
    stageStream.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _getFuture() async {
    ServersNotifier serversNotifier = Provider.of(context, listen: false);
    await Future.delayed(const Duration(seconds: 2));
    return serversNotifier.vpnStage == OVPN.vpnConnected ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier userNotifier = Provider.of(context, listen: false);
    ServersNotifier serversNotifier = Provider.of(context, listen: false);
    userNotifier.getProfiles(context);
    checkBannedUser();
    points = [
      Point(
          id: '1',
          coordinates: GlobeCoordinates(
              double.parse(widget.user.logs!.latitude!),
              double.parse(widget.user.logs!.longitude!)),
          label: 'your_location'
              .tr(namedArgs: {'country': '${widget.user.logs!.country}'}),
          labelBuilder: pointLabelBuilder,
          style: const PointStyle(color: CupertinoColors.systemRed, size: 6)),
      Point(
          id: '2',
          coordinates: GlobeCoordinates(
              double.parse(userNotifier.user.servers!.latitude!),
              double.parse(userNotifier.user.servers!.longitude!)),
          style: const PointStyle(color: CupertinoColors.systemGreen)),
    ];
    connections = [
      PointConnection(
          id: '1',
          start: points[0].coordinates,
          end: points[1].coordinates,
          isMoving: true,
          labelBuilder: connectionLabelBuilder,
          isLabelVisible: false,
          style: const PointConnectionStyle(
              type: PointConnectionType.solid,
              color: CupertinoColors.systemRed,
              lineWidth: 3,
              dashSize: 4,
              spacing: 10),
          label: 'connected_to'.tr(
              namedArgs: {'country': '${userNotifier.user.servers!.country}'})),
    ];
    _controller.onLoaded = () {
      _controller.addPoint(points.first);
      setState(() {});
    };

    for (var point in points) {
      _controller.focusOnCoordinates(
          serversNotifier.vpnStage == OVPN.vpnConnected
              ? GlobeCoordinates(
                  double.parse(userNotifier.user.servers!.latitude!),
                  double.parse(userNotifier.user.servers!.longitude!))
              : GlobeCoordinates(double.parse(widget.user.logs!.latitude!),
                  double.parse(widget.user.logs!.longitude!)),
          animate: true);
      serversNotifier.vpnStage == OVPN.vpnConnected
          ? _controller.addPointConnection(connections.first, animateDraw: true)
          : _controller.removePointConnection(point.id);
    }
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: Settings(user: widget.user),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 250, child: ServerScreen()),
                // Connection Status and Map
                Expanded(
                    child: Stack(children: [
                  FlutterEarthGlobe(
                    controller: _controller,
                    radius: 100,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        serversNotifier.vpnStage == OVPN.vpnConnected
                            ? 'connected'.tr()
                            : 'disconnected'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          color: serversNotifier.vpnStage == OVPN.vpnConnected
                              ? CupertinoColors.activeGreen
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LoadSwitch(
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
                                    ? CupertinoColors.activeGreen
                                        .withOpacity(0.2)
                                    : CupertinoColors.systemRed
                                        .withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          );
                        },
                        height: 25.h,
                        width: Platform.isMacOS ? 35.sp : 40.w,
                        value: serversNotifier.vpnStage == OVPN.vpnConnected
                            ? true
                            : false,
                        future: _getFuture,
                        style: SpinStyle.threeInOut,
                        onTap: (v) {
                          if (kDebugMode) {
                            print('Tapping while value is $v');
                          }
                        },
                        spinColor: (value) => value
                            ? const Color.fromARGB(255, 41, 232, 31)
                            : const Color.fromARGB(255, 255, 77, 77),
                        spinStrokeWidth: 3,
                        onChange: (bool bool) async {
                          if (serversNotifier.vpnStage == OVPN.vpnConnected) {
                            return showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text("disconnected".tr()),
                                  content: Text("disconnected_desc".tr()),
                                  actions: <Widget>[
                                    CupertinoButton(
                                        onPressed: () {
                                          showProgress = false;

                                          OVPN.stopVpn();
                                          Navigator.pop(context, true);
                                        },
                                        child: Text(
                                          'disconnect'.tr(),
                                          style: const TextStyle(
                                              color: CupertinoColors.systemRed),
                                        )),
                                    CupertinoButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                        showProgress == false;
                                      },
                                      child: Text(
                                        "cancel".tr(),
                                        style: const TextStyle(),
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          } else {
                            OVPN.startVpn(
                                userNotifier.user.servers!.ovpnConfig!,
                                userNotifier.user.servers!.country!);
                          }
                        },
                      )
                    ],
                  ),
                ])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
