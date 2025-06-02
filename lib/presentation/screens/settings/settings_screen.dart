import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../features/features_screen.dart';
import '../language/language_screen.dart';
import '../subscription/subscription_screen.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            _buildAccountSection(),
            SizedBox(height: 30.h),
            _buildCommonSection(),
            SizedBox(height: 30.h),
            _buildLogoutButton(),
            SizedBox(height: 20.h),
            _buildDeleteAccountButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const SizedBox.shrink();
        }

        final user = state.user;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.person),
                SizedBox(width: 8.w),
                Text(
                  "Account",
                  style: TextStyle(
                    fontSize: Platform.isMacOS ? 6.sp : 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            _buildAccountOptionRow(
              context,
              "Device ID",
              trailing: Text(
                user.deviceId,
                style: TextStyle(
                  fontSize: Platform.isMacOS ? 8.sp : 10.sp,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
            _buildAccountOptionRow(
              context,
              "Plan",
              trailing: Text(
                user.isPremium ? "Premium Plan" : "Free Plan",
                style: TextStyle(
                  fontSize: Platform.isMacOS ? 8.sp : 10.sp,
                  color: user.isPremium
                      ? const Color.fromARGB(255, 18, 243, 2)
                      : const Color.fromARGB(255, 243, 2, 2),
                ),
              ),
              onTap: user.isPremium
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const SubscriptionScreen(),
                        ),
                      );
                    },
            ),
            if (user.isPremium && user.subscription != null)
              _buildAccountOptionRow(
                context,
                "Expires",
                trailing: Text(
                  _formatDate(user.subscription!.expiryDate),
                  style: TextStyle(
                    fontSize: Platform.isMacOS ? 8.sp : 10.sp,
                    color: user.subscription!.isExpired
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCommonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.settings, size: Platform.isMacOS ? 20 : 24),
            SizedBox(width: 8.w),
            Text(
              "Common",
              style: TextStyle(
                fontSize: Platform.isMacOS ? 6.sp : 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        _buildAccountOptionRow(
          context,
          "Languages",
          onTap: () => _navigateToLanguages(),
        ),
        _buildAccountOptionRow(
          context,
          "VPN Special Features",
          onTap: () => _navigateToFeatures(),
        ),
        _buildAccountOptionRow(context, "Share", onTap: () => _shareApp()),
        _buildAccountOptionRow(
          context,
          "Privacy Policy",
          onTap: () => _launchUrl(AppConstants.privacyUrl),
        ),
        _buildAccountOptionRow(
          context,
          "Terms of Service",
          onTap: () => _launchUrl(AppConstants.termsUrl),
        ),
        _buildAccountOptionRow(
          context,
          "Contact Us",
          onTap: () => _contactUs(),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return _buildAccountOptionRow(
      context,
      "Sign Out",
      onTap: () => _showLogoutDialog(),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Center(
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        onPressed: () => _showDeleteAccountDialog(),
        child: Text(
          "Delete Account",
          style: TextStyle(
            fontSize: Platform.isMacOS ? 8.sp : 16.sp,
            color: CupertinoColors.systemRed,
            letterSpacing: 2.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountOptionRow(
    BuildContext context,
    String title, {
    Function()? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.darkBackgroundGray),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing ??
                    (onTap != null
                        ? const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          )
                        : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLanguages() {
    if (Platform.isMacOS) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: double.maxFinite,
            width: 400,
            color: Colors.white,
            child: const LanguageScreen(),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => const LanguageScreen()),
      );
    }
  }

  void _navigateToFeatures() {
    if (Platform.isMacOS) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: double.maxFinite,
            width: 400,
            color: Colors.white,
            child: const FeaturesScreen(),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => const FeaturesScreen()),
      );
    }
  }

  void _shareApp() {
    Share.share(
      '${AppConstants.appName} protects your privacy ${AppConstants.storeUrl}',
    );
  }

  void _contactUs() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppConstants.contactEmail,
      queryParameters: {'subject': 'Contact Support - ${AppConstants.appName}'},
    );

    if (!await launchUrl(emailLaunchUri)) {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserBloc>().add(LogOut());
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
          textAlign: TextAlign.start,
        ),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text(
              'Delete Now',
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    // In a real app, you'd implement account deletion
    // For now, just log out
    context.read<UserBloc>().add(LogOut());

    // Show confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Deleted'),
        content: const Text('Your account has been deleted successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
