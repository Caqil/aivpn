import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/features/index.dart';

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  @override
  void initState() {
    consent();
    super.initState();
  }

  void accept() {
    navigatorKey.currentState!.pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (_) {
          return const Login();
        },
      ),
      (route) => false,
    );
  }

  Future<void> consent() async {
    ConsentDebugSettings debugSettings = ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
        testIdentifiers: [
          '755D41BD-57F4-4188-928B-B58F25AC2ECA',
          '19C385DE-0C84-46CE-A70B-07B84476B685'
        ]);

    final params =
        ConsentRequestParameters(consentDebugSettings: debugSettings);
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        debugPrint('AAT request');
        // The consent information state was updated.
        // You are now ready to check if a form is available.
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          loadForm();
        } else {
          debugPrint('AAT Consent Form unavailable');
        }
      },
      (FormError error) {
        debugPrint('AAT error: ${error.message}');
        // Handle the error
      },
    );
  }

  void loadForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        var status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show(
            (FormError? formError) {
              // Handle dismissal by reloading form
              loadForm();
            },
          );
        }
      },
      (FormError formError) {
        // Handle the error
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome to 360 AI VPN '),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use 360 AI VPN.'),
                  const SizedBox(height: 10),
                  Text(
                    '1. What Information We Collect',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const Text(
                    '''We may collect:
🟡 Personal Information: Like your name, email, and login details when you sign up.
🟡 Usage Information: Such as your IP address and how you use the app.
🟡 Cookies: We may use cookies to improve your experience.''',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '2. How We Use Your Information',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const Text('''We use your information to:
🟡 Providing and Improving Services: To deliver the features and functionality of 360 AI VPN App, personalize your experience, and enhance the quality of our services.
🟡 Communications: To communicate with you about updates, promotions, and other relevant information related to 360 AI VPN App.
🟡 Analytics and Research: To analyze usage patterns, monitor performance, and conduct research to improve 360 AI VPN App and develop new features.
🟡 Legal Compliance: To comply with applicable laws, regulations, and legal processes, and to protect our rights and the rights of our users.'''),
                  const SizedBox(height: 10),
                  Text(
                    '3. How We Keep Your Information Secure',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const Text(
                    '🟡 We take measures to protect your information, but remember no method is 100% secure.',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '4. Third-Party Services',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const Text(
                    '🟡 360 AI VPN app may link to other sites like firebase, admob and google analytics',
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CupertinoButton.filled(
                        onPressed: accept,
                        child: const Text('Accept and Continue')),
                  ),
                ],
              )),
        ));
  }
}
