import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/core/admob/admob_service.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:safer_vpn/src/core/infrastructure/language/lang_notifier.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (Platform.isMacOS || Platform.isWindows) {
    await windowManager.ensureInitialized();
    SystemChannels.platform.invokeMethod<void>(
        'SystemChrome.setEnabledSystemUIMode',
        <String, dynamic>{'enabledSystemUIOverlays': []});
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 450),
      maximumSize: Size(800, 450),
      minimumSize: Size(800, 450),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    AdMobService.initialize();
    AdMobService.loadAppOpenAd();
  }
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => ServersNotifier(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => LangController(),
          lazy: true,
        ),
      ],
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return true;
        },
        child: Consumer<LangController>(
          builder: (context, value, child) => EasyLocalization(
            path: 'assets/languages',
            supportedLocales: value.locales!,
            useOnlyLangCode: true,
            child: ScreenUtilInit(
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  ServersNotifier.getStateVPN(context);
                  return MaterialApp(
                    navigatorKey: navigatorKey,
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    home: const SplashPage(),
                    theme: ThemeData(
                      brightness: Brightness.dark,
                      primaryColor: CupertinoColors.systemBlue,
                      appBarTheme: const AppBarTheme(
                        backgroundColor: CupertinoColors.black,
                      ),
                      scaffoldBackgroundColor: CupertinoColors.black,
                    ),
                  );
                }),
          ),
        ),
      )));
}
