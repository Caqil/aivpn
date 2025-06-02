import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../widgets/subscription_packages_widget.dart';
import '../../../core/constants/app_constants.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Platform.isMacOS ? false : true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Platform.isMacOS
              ? Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserPurchaseSuccess) {
          _showSuccessDialog();
        } else if (state is UserPurchaseError) {
          _showErrorDialog(state.message);
        }
      },
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  'Try VPN Premium',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),

                // Features
                _buildFeaturesList(),
                SizedBox(height: 30.h),

                // Subscription Packages
                const SubscriptionPackagesWidget(),
                SizedBox(height: 20.h),

                // Terms and Privacy
                _buildTermsAndPrivacy(),
                SizedBox(height: 20.h),

                // Restore Purchases
                _buildRestorePurchases(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserPurchaseSuccess) {
          _showSuccessDialog();
        } else if (state is UserPurchaseError) {
          _showErrorDialog(state.message);
        }
      },
      child: Center(
        child: Row(
          children: [
            // Left side - Features
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: Platform.isMacOS ? 70 : 120,
                      width: Platform.isMacOS ? 70 : 120,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/icon.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Try VPN Premium',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    _buildFeaturesList(),
                    SizedBox(height: 20.h),
                    _buildRestorePurchases(),
                  ],
                ),
              ),
            ),

            // Right side - Packages and Terms
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SubscriptionPackagesWidget(),
                    SizedBox(height: 20.h),
                    _buildTermsAndPrivacy(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Protects your privacy',
      'Indulge streaming',
      'Securely access',
      'Virtual locations',
      'No ads',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          const TextSpan(
            text:
                'Your subscription will auto-renew. By continuing, you agree to our ',
            style: TextStyle(color: CupertinoColors.white),
          ),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              color: CupertinoColors.systemBlue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl(AppConstants.termsUrl),
          ),
          const TextSpan(
            text: ' & ',
            style: TextStyle(color: CupertinoColors.white),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: CupertinoColors.systemBlue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl(AppConstants.privacyUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildRestorePurchases() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final isLoading = state is UserPurchasing;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  context.read<UserBloc>().add(RestorePurchases());
                },
          child: Text(
            'Restore Purchases',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: isLoading ? Colors.grey : Colors.blue,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text(
          'Your purchase was successful! Enjoy premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to main screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
}
