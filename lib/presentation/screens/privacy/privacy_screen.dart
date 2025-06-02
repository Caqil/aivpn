import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../../core/constants/app_constants.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  void initState() {
    super.initState();
    _initializeConsent();
  }

  void _initializeConsent() {
    // Initialize Google Mobile Ads consent
    ConsentDebugSettings debugSettings = ConsentDebugSettings(
      debugGeography: DebugGeography.debugGeographyEea,
      testIdentifiers: [
        '755D41BD-57F4-4188-928B-B58F25AC2ECA',
        '19C385DE-0C84-46CE-A70B-07B84476B685',
      ],
    );

    final params = ConsentRequestParameters(
      consentDebugSettings: debugSettings,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadConsentForm();
        }
      },
      (FormError error) {
        debugPrint('Consent error: ${error.message}');
      },
    );
  }

  void _loadConsentForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        var status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((FormError? formError) {
            _loadConsentForm();
          });
        }
      },
      (FormError formError) {
        debugPrint('Consent form error: ${formError.message}');
      },
    );
  }

  void _acceptAndContinue() {
    // Create user and navigate to main app
    context.read<UserBloc>().add(CreateUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to ${AppConstants.appName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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

              _buildSection('1. What Information We Collect', '''We may collect:
🟡 Personal Information: Like your device ID and usage details when you use the app.
🟡 Usage Information: Such as connection logs and how you use the app.
🟡 Analytics: We may use analytics to improve your experience.'''),

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
                    onPressed: _acceptAndContinue,
                    child: const Text(
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
            fontSize: 17.sp,
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
