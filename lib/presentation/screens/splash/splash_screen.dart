// lib/presentation/screens/splash/splash_screen.dart - Fixed
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_event.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../home/home_screen.dart';
import '../privacy/privacy_screen.dart';
import 'loading_splash_screen.dart';
import '../../../data/services/app_initialization_service.dart';
import '../../../injection_container.dart' as di;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AppInitializationService _initService;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initService = di.sl<AppInitializationService>();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      print('Starting splash screen initialization...');

      // Wait for splash animation
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) {
        print('Widget not mounted, stopping initialization');
        return;
      }

      print('Starting app initialization service...');

      // Initialize the app and handle user creation/loading
      final result = await _initService.initializeApp();

      if (!mounted) {
        print('Widget not mounted after initialization');
        return;
      }

      if (result.success && result.userProfile != null) {
        print('Initialization successful, setting up app state...');

        // Update servers from user profile
        final servers = result.userProfile!.servers;
        if (servers.isNotEmpty) {
          print('Loading ${servers.length} servers from profile');
          context.read<ServerBloc>().add(LoadServersFromProfile(servers));
        } else {
          print('No servers found in profile, loading from API');
          context.read<ServerBloc>().add(LoadServers());
        }

        // Create or update user in UserBloc
        context.read<UserBloc>().add(CreateUser());

        // Navigate to home screen
        _navigateToHome();
      } else {
        // Show error and navigate to privacy screen
        print('Initialization failed: ${result.message}');
        _showErrorAndNavigateToPrivacy(result.message);
      }
    } catch (e) {
      print('Splash screen initialization error: $e');

      if (!mounted) return;

      // Handle initialization errors
      _showErrorAndNavigateToPrivacy(
        'Failed to initialize app: ${e.toString()}',
      );
    } finally {
      _isInitializing = false;
    }
  }

  void _navigateToHome() {
    if (mounted) {
      print('Navigating to home screen');
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _navigateToPrivacy() {
    if (mounted) {
      print('Navigating to privacy screen');
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const PrivacyScreen()),
      );
    }
  }

  void _showErrorAndNavigateToPrivacy(String error) {
    print('Initialization error: $error');

    // For now, navigate to privacy screen where user can accept terms and create account
    // In a real app, you might want to show an error dialog first
    _navigateToPrivacy();
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingSplashScreen();
  }
}
