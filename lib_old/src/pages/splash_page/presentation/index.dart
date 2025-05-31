import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/home_page/index_desktop.dart';
import 'package:safer_vpn/src/pages/home_page/index.dart';
import 'package:safer_vpn/src/pages/splash_page/presentation/loading_splash_page.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/pages/splash_page/presentation/privacy.dart';

class SplashPage extends StatefulWidget {
  static var routeName = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  Widget appLoading({bool adaptive = false, double? width, double? height}) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: const CupertinoActivityIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    Future<void> initializeApp(AuthNotifier authNotifier) async {
      await Future.delayed(const Duration(seconds: 2));
      await authNotifier.checkToken();
      await authNotifier.getProfiles(context);
    }

    return FutureBuilder<void>(
      future: initializeApp(authNotifier),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (authNotifier.token.isNotEmpty) {
            return FutureBuilder<User?>(
              future: authNotifier.getProfiles(context),
              builder: (BuildContext context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return appLoading();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Platform.isMacOS
                          ? HomePageDesk(user: authNotifier.user)
                          : HomePage(
                              user: authNotifier.user,
                            );
                    }
                }
              },
            );
          } else {
            return const Privacy();
          }
        } else {
          return const LoadingSplashPage();
        }
      },
    );
  }
}
