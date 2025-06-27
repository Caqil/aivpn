// lib/app.dart - Fixed with ScreenUtil initialization
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'injection_container.dart' as di;
import 'presentation/bloc/server/server_bloc.dart';
import 'presentation/bloc/vpn/vpn_bloc.dart';
import 'presentation/bloc/user/user_bloc.dart';
import 'presentation/bloc/user_creation/user_creation_bloc.dart';
import 'presentation/screens/splash/splash_screen.dart';

class VpnApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ServerBloc>(create: (context) => di.sl<ServerBloc>()),
        BlocProvider<VpnBloc>(create: (context) => di.sl<VpnBloc>()),
        BlocProvider<UserBloc>(create: (context) => di.sl<UserBloc>()),
        BlocProvider<UserCreationBloc>(
          create: (context) => di.sl<UserCreationBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone 11 Pro design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'VPN App',
            theme: _buildTheme(),
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.purple,
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      cardColor: const Color(0xFF16213E),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
