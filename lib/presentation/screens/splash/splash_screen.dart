import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_event.dart';
import '../home/home_screen.dart';
import '../privacy/privacy_screen.dart';
import 'loading_splash_screen.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait a bit for the splash animation
    await Future.delayed(const Duration(seconds: 2));

    // Load user and check if exists
    if (mounted) {
      context.read<UserBloc>().add(LoadUser());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          // User exists, load servers and navigate to home
          context.read<ServerBloc>().add(LoadServers());
          _navigateToHome();
        } else if (state is UserNotFound) {
          // No user found, show privacy screen
          _navigateToPrivacy();
        } else if (state is UserError) {
          // Error loading user, try to create new user
          context.read<UserBloc>().add(CreateUser());
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const LoadingSplashScreen();
          }

          // For other states, show loading while navigation is happening
          return const LoadingSplashScreen();
        },
      ),
    );
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(CupertinoPageRoute(builder: (context) => HomeScreen()));
    }
  }

  void _navigateToPrivacy() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const PrivacyScreen()),
      );
    }
  }
}
