import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user_creation/user_creation_bloc.dart';
import '../../bloc/user_creation/user_creation_event.dart';
import '../../bloc/user_creation/user_creation_state.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_event.dart';
import '../home/home_screen.dart';
import '../privacy/privacy_screen.dart';
import 'loading_splash_screen.dart';
import '../../../core/services/revenuecat_service.dart';

class AppInitializationScreen extends StatefulWidget {
  const AppInitializationScreen({super.key});

  @override
  State<AppInitializationScreen> createState() =>
      _AppInitializationScreenState();
}

class _AppInitializationScreenState extends State<AppInitializationScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize RevenueCat and get user ID
      await RevenueCatService.instance.initialize();
      final userId = RevenueCatService.instance.deviceId;

      if (userId == null || userId.isEmpty) {
        throw Exception('Failed to get device ID');
      }

      // Check if user exists in the system
      if (mounted) {
        context.read<UserCreationBloc>().add(CheckUserExists(userId));
      }
    } catch (e) {
      print('App initialization error: $e');
      if (mounted) {
        _navigateToPrivacy();
      }
    }
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

  void _createNewUser(String userId) {
    // Get subscription status
    RevenueCatService.instance
        .getCustomerInfo()
        .then((customerInfo) {
          final isPremium = RevenueCatService.instance.isPremium(customerInfo);

          if (mounted) {
            context.read<UserCreationBloc>().add(
              CreateUserAccount(userId: userId, isPremium: isPremium),
            );
          }
        })
        .catchError((error) {
          // Create as free user if RevenueCat fails
          if (mounted) {
            context.read<UserCreationBloc>().add(
              CreateUserAccount(userId: userId, isPremium: false),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocListener<UserCreationBloc, UserCreationState>(
        listener: (context, state) {
          if (state is UserProfileLoaded) {
            // User exists and profile loaded successfully
            final servers = state.userProfile.servers;

            // Update server repository with servers from profile
            if (servers.isNotEmpty) {
              context.read<ServerBloc>().add(LoadServersFromProfile(servers));

              // Select first server if none selected
              context.read<ServerBloc>().add(SelectServer(servers.first));
            }

            _navigateToHome();
          } else if (state is UserNotFound) {
            // User doesn't exist, create new user
            final userId = RevenueCatService.instance.deviceId;
            if (userId != null && userId.isNotEmpty) {
              _createNewUser(userId);
            } else {
              _navigateToPrivacy();
            }
          } else if (state is UserCreationSuccess) {
            // New user created successfully
            final servers = state.userProfile.servers;

            // Update server repository with servers from profile
            if (servers.isNotEmpty) {
              context.read<ServerBloc>().add(LoadServersFromProfile(servers));

              // Select first server
              context.read<ServerBloc>().add(SelectServer(servers.first));
            }

            _navigateToHome();
          } else if (state is UserCreationError) {
            // Error creating user or loading profile
            print('User creation error: ${state.message}');
            _navigateToPrivacy();
          }
        },
        child: BlocBuilder<UserCreationBloc, UserCreationState>(
          builder: (context, state) {
            if (state is UserCreationLoading) {
              return const LoadingSplashScreen();
            }

            // Show loading screen for all other states while processing
            return const LoadingSplashScreen();
          },
        ),
      ),
    );
  }
}
