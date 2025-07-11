// lib/presentation/screens/settings/enhanced_settings_screen.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/vpn/vpn_bloc.dart';
import '../../bloc/vpn/vpn_state.dart';
import '../features/features_screen.dart';
import '../language/language_screen.dart';
import '../subscription/subscription_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/app_initialization_service.dart';
import '../../../injection_container.dart' as di;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AppInitializationService _initService;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isRetrying = false;
  bool _autoConnect = false;
  bool _notifications = true;
  bool _hapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _initService = di.sl<AppInitializationService>();
    _setupAnimations();
    _loadSettings();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _loadSettings() {
    // Load settings from shared preferences
    // This is a placeholder - implement actual settings loading
    setState(() {
      _autoConnect = false;
      _notifications = true;
      _hapticFeedback = true;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(position: _slideAnimation, child: _buildBody()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      title: const Text(
        'Settings',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: BlocBuilder<VpnBloc, VpnState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: state is VpnConnected
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: state is VpnConnected
                        ? Colors.green.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: state is VpnConnected
                            ? Colors.green
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state is VpnConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: state is VpnConnected
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 24,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountSection(),
            _buildAppSettings(),
            _buildSupportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return _buildLoadingCard();
        }

        final user = state.user;
        return _buildSection(
          title: 'Account',
          icon: CupertinoIcons.person_circle,
          children: [
            _buildAccountCard(user),
            const SizedBox(height: 16),
            _buildSubscriptionCard(user),
          ],
        );
      },
    );
  }

  Widget _buildAccountCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.person_fill,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device ID',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.deviceId,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Clipboard.setData(
                              ClipboardData(text: user.deviceId),
                            );
                            _showSnackBar('Device ID copied to clipboard');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.copy,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(user) {
    return GestureDetector(
      onTap: user.isPremium ? null : () => _navigateToSubscription(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: user.isPremium
                ? [
                    Colors.amber.withOpacity(0.2),
                    Colors.orange.withOpacity(0.2),
                  ]
                : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: user.isPremium
                ? Colors.amber.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: user.isPremium
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                user.isPremium ? Icons.diamond : Icons.lock,
                color: user.isPremium ? Colors.amber : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.isPremium ? 'Premium Plan' : 'Free Plan',
                    style: TextStyle(
                      color: user.isPremium ? Colors.amber : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.isPremium
                        ? 'Unlimited access to all features'
                        : 'Upgrade to unlock premium features',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  if (user.isPremium && user.subscription != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Expires: ${_formatDate(user.subscription!.expiryDate)}',
                      style: TextStyle(
                        color: user.subscription!.isExpired
                            ? Colors.red
                            : Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!user.isPremium)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettings() {
    return _buildSection(
      title: 'App Settings',
      icon: CupertinoIcons.settings,
      children: [
        _buildSwitchTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Receive connection status updates',
          value: _notifications,
          onChanged: (value) {
            setState(() {
              _notifications = value;
            });
            _saveSettings();
          },
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          icon: Icons.vibration,
          title: 'Haptic Feedback',
          subtitle: 'Feel vibrations for interactions',
          value: _hapticFeedback,
          onChanged: (value) {
            setState(() {
              _hapticFeedback = value;
            });
            _saveSettings();
          },
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'Change app language',
          onTap: () => _navigateToLanguages(),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.star,
          title: 'VPN Features',
          subtitle: 'Explore all VPN capabilities',
          onTap: () => _navigateToFeatures(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support & Info',
      icon: CupertinoIcons.question_circle,
      children: [
        _buildActionTile(
          icon: Icons.share,
          title: 'Share App',
          subtitle: 'Tell friends about this VPN',
          onTap: () => _shareApp(),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () => _launchUrl(AppConstants.privacyUrl),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'View terms and conditions',
          onTap: () => _launchUrl(AppConstants.termsUrl),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.support_agent,
          title: 'Contact Support',
          subtitle: 'Get help from our team',
          onTap: () => _contactUs(),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        trailing: Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
            value: value,
            onChanged: (newValue) {
              if (_hapticFeedback) HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: Colors.blue,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              if (_hapticFeedback) HapticFeedback.lightImpact();
              onTap();
            },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (textColor ?? Colors.blue).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.blue,
                      ),
                    ),
                  )
                : Icon(icon, color: textColor ?? Colors.blue, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: (textColor ?? Colors.white).withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: (textColor ?? Colors.white).withOpacity(0.5),
            size: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToSubscription() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const SubscriptionScreen()),
    );
  }

  void _navigateToLanguages() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const LanguageScreen()),
    );
  }

  void _navigateToFeatures() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const FeaturesScreen()),
    );
  }

  // Action methods
  void _retryConnection() async {
    setState(() {
      _isRetrying = true;
    });

    try {
      await _initService.initializeApp();
      _showSnackBar('Connection retry successful', isSuccess: true);
    } catch (e) {
      _showSnackBar('Connection retry failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  void _testConnection() {
    _showSnackBar('Running connection test...', duration: 3);
    // Implement connection test logic
  }

  void _shareApp() {
    Share.share(
      '${AppConstants.appName} - Secure, fast, and private VPN. Download now: ${AppConstants.storeUrl}',
    );
  }

  void _contactUs() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppConstants.contactEmail,
      queryParameters: {
        'subject': 'Support Request - ${AppConstants.appName}',
        'body': 'Please describe your issue or question here...',
      },
    );

    if (!await launchUrl(emailLaunchUri)) {
      _showSnackBar('Could not open email client', isError: true);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      _showSnackBar('Could not open URL', isError: true);
    }
  }

  void _saveSettings() {
    // Implement settings saving logic
    // Save to SharedPreferences or another storage solution
  }

  // Dialog methods
  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You\'ll need to sign in again to access your account.',
        ),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserBloc>().add(LogOut());
              _showSnackBar('Signed out successfully', isSuccess: true);
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
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.\n\nAre you absolutely sure?',
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
              'Delete Forever',
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    // In a real app, implement actual account deletion
    context.read<UserBloc>().add(LogOut());
    _showSnackBar('Account deleted successfully', isSuccess: true);
  }

  // Utility methods
  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    int duration = 2,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : isSuccess
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isError
            ? Colors.red.withOpacity(0.9)
            : isSuccess
            ? Colors.green.withOpacity(0.9)
            : Colors.blue.withOpacity(0.9),
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
