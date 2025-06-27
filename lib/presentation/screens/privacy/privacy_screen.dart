// lib/presentation/screens/privacy/privacy_screen.dart - Fixed without ScreenUtil dependency
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_event.dart';
import '../home/home_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/app_initialization_service.dart';
import '../../../injection_container.dart' as di;

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late AppInitializationService _initService;
  bool _isCreatingUser = false;

  @override
  void initState() {
    super.initState();
    _initService = di.sl<AppInitializationService>();
  }

  void _acceptAndContinue() async {
    if (_isCreatingUser) return;

    setState(() {
      _isCreatingUser = true;
    });

    try {
      print('User accepted privacy policy, creating user...');

      // Force user creation through initialization service
      final result = await _initService.forceUserCreation();

      if (!mounted) return;

      if (result.success && result.userProfile != null) {
        print('User created successfully: ${result.userProfile!.username}');

        // Update servers from user profile
        final servers = result.userProfile!.servers;
        if (servers.isNotEmpty) {
          context.read<ServerBloc>().add(LoadServersFromProfile(servers));
        } else {
          context.read<ServerBloc>().add(LoadServers());
        }

        // Create user in UserBloc
        context.read<UserBloc>().add(CreateUser());

        // Navigate to home screen
        _navigateToHome();
      } else {
        // Show error
        _showErrorDialog('Failed to create user account. Please try again.');
      }
    } catch (e) {
      print('Error creating user: $e');
      if (mounted) {
        _showErrorDialog('Failed to create user account: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingUser = false;
        });
      }
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to ${AppConstants.appName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            // User successfully created and loaded
            _navigateToHome();
          } else if (state is UserError) {
            // Show error
            _showErrorDialog(state.message);
            setState(() {
              _isCreatingUser = false;
            });
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use 360 AI VPN.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 20),

                _buildSection(
                  '1. What Information We Collect',
                  '''We may collect:
🟡 Personal Information: Like your device ID and usage details when you use the app.
🟡 Usage Information: Such as connection logs and how you use the app.
🟡 Analytics: We may use analytics to improve your experience.''',
                ),

                _buildSection(
                  '2. How We Use Your Information',
                  '''We use your information to:
🟡 Providing and Improving Services: To deliver the features and functionality of 360 AI VPN App, personalize your experience, and enhance the quality of our services.
🟡 Communications: To communicate with you about updates, promotions, and other relevant information related to 360 AI VPN App.
🟡 Analytics and Research: To analyze usage patterns, monitor performance, and conduct research to improve 360 AI VPN App and develop new features.
🟡 Legal Compliance: To comply with applicable laws, regulations, and legal processes, and to protect our rights and the rights of our users.''',
                ),

                _buildSection(
                  '3. How We Keep Your Information Secure',
                  '🟡 We take measures to protect your information, but remember no method is 100% secure.',
                ),

                _buildSection(
                  '4. Third-Party Services',
                  '🟡 360 AI VPN app may integrate with services like RevenueCat for subscriptions, AdMob for advertising, and analytics services.',
                ),

                const SizedBox(height: 40),

                // Accept Button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: _isCreatingUser ? null : _acceptAndContinue,
                      child: _isCreatingUser
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Accept and Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 17, // Removed .sp to avoid initialization error
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
