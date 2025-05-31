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
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/core/admob/admob_service.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/core/infrastructure/server/ovpn.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/server/server_screen.dart';
import 'package:safer_vpn/src/pages/setting/setting.dart';
import 'package:safer_vpn/src/pages/subscription_page/subscription.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late StreamSubscription stageStream;
  late List<Point> points;
  late FlutterEarthGlobeController _controller;
  List<PointConnection> connections = [];
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdMobService.showAppOpenAdIfAvailable();
    }
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
    super.initState();
    AdMobService.createInterstitialAd();
    AdMobService.createRewardedAd();
    WidgetsBinding.instance.addObserver(this);
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
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: serversNotifier.vpnStage == OVPN.vpnConnected
                  ? RichText(
                      key: const ValueKey(0),
                      text: TextSpan(
                        text: 'Status:',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'connected'.tr(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.systemGreen)),
                        ],
                      ),
                    )
                  : RichText(
                      text: TextSpan(
                        text: 'Status:',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'disconnected'.tr(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.systemRed)),
                        ],
                      ),
                    ),
            ),
            leading: !userNotifier.user.subscription!.expiryAt!
                    .isBefore(DateTime.now())
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const SubscriptionScreen()),
                      );
                    },
                    child: Transform.scale(
                        scale: 0.5,
                        child: Image.asset(
                          'assets/icons/diamond.png',
                          height: 15,
                          width: 15,
                        )),
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => Settings(
                              user: widget.user,
                            )),
                  );
                },
                icon: const Icon(CupertinoIcons.settings),
              ),
            ]),
        body: Stack(
          children: [
            FlutterEarthGlobe(
              controller: _controller,
              radius: 120,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.darkBackgroundGray,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => const ServerScreen()),
                              );
                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 18),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                        'assets/icons/flags/${userNotifier.user.servers!.country!}.png'
                                            .toLowerCase()),
                                    const SizedBox(width: 5),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${userNotifier.user.servers!.country!}, ${userNotifier.user.servers!.ipAddress}",
                                        ),
                                        SizedBox(
                                          width: 150.w,
                                          child: Text(
                                              userNotifier.user.servers!.state!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: Platform.isMacOS
                                                      ? 9.sp
                                                      : 10.sp)),
                                        )
                                      ],
                                    )
                                  ],
                                ))),
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: Center(
                                child: LoadSwitch(
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
                              value:
                                  serversNotifier.vpnStage == OVPN.vpnConnected
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
                                if (serversNotifier.vpnStage ==
                                    OVPN.vpnConnected) {
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
                                                Future.delayed(Duration.zero,
                                                    () {
                                                  !widget.user.subscription!
                                                          .expiryAt!
                                                          .isBefore(
                                                              DateTime.now())
                                                      ? null
                                                      : AdMobService
                                                          .showInterstitialAd();
                                                });
                                                OVPN.stopVpn();
                                                Navigator.pop(context, true);
                                              },
                                              child: Text(
                                                'disconnect'.tr(),
                                                style: const TextStyle(
                                                    color: CupertinoColors
                                                        .systemRed),
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
                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    !widget.user.subscription!.expiryAt!
                                            .isBefore(DateTime.now())
                                        ? null
                                        : AdMobService.showRewardedAd();
                                  });
                                  OVPN.startVpn(
                                      userNotifier.user.servers!.ovpnConfig!,
                                      userNotifier.user.servers!.country!);
                                }
                              },
                            ))),
                      ],
                    ),
                  )),
            ),
          ],
        ));
  }
}
