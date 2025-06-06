
import 'package:aivpn/domain/entities/server.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_event.dart';
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

  @override
  void initState() {
    super.initState();
    _initService = di.sl<AppInitializationService>();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Initialize the app and handle user creation/loading
      final result = await _initService.initializeApp();

      if (result.success && result.userProfile != null) {
        // Update servers from user profile
        final servers = result.userProfile!.servers;
        if (servers.isNotEmpty) {
          context.read<ServerBloc>().add(LoadServersFromProfile(servers));
        }

        // Navigate to home screen
        _navigateToHome();
      } else {
        // Show error and navigate to privacy screen
        _showErrorAndNavigateToPrivacy(result.message);
      }
    } catch (e) {
      // Handle initialization errors
      _showErrorAndNavigateToPrivacy(
        'Failed to initialize app: ${e.toString()}',
      );
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

  void _showErrorAndNavigateToPrivacy(String error) {
    print('Initialization error: $error');

    // For now, navigate to privacy screen
    // In a real app, you might want to show an error dialog first
    _navigateToPrivacy();
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingSplashScreen();
  }
}

class LoadServersFromProfile extends ServerEvent {
  final List<Server> servers;

  LoadServersFromProfile(this.servers);

  @override
  List<Object?> get props => [servers];
}
