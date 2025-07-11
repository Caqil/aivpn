import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  final ScrollController _scrollController = ScrollController();
  int _selectedFeatureIndex = -1;

  final List<Feature> _features = [
    Feature(
      title: 'Torrenting Support',
      description:
          'Optimized servers for safe and fast torrenting with unlimited bandwidth and P2P optimization.',
      icon: Icons.download,
      color: Colors.green,
      benefit: 'Download safely without speed limits',
      details:
          'Dedicated P2P servers in 20+ countries with no bandwidth restrictions.',
    ),
    Feature(
      title: 'DNS Leak Protection',
      description:
          'Advanced DNS leak protection ensures all your requests are routed through our secure VPN tunnel.',
      icon: Icons.security,
      color: Colors.blue,
      benefit: 'Complete anonymity guaranteed',
      details: 'Military-grade DNS security with real-time leak detection.',
    ),
    Feature(
      title: 'Automatic WiFi Protection',
      description:
          'Smart auto-connect feature activates VPN protection when joining unsecured WiFi networks.',
      icon: Icons.wifi_protected_setup,
      color: Colors.orange,
      benefit: 'Always protected on public WiFi',
      details:
          'Automatically detects and secures unsafe networks in cafes, airports, hotels.',
    ),
    Feature(
      title: 'Simultaneous Connections',
      description:
          'Connect unlimited devices simultaneously with a single premium account.',
      icon: Icons.devices,
      color: Colors.purple,
      benefit: 'Protect your entire digital life',
      details: 'Works on phones, tablets, laptops, smart TVs, and routers.',
    ),
    Feature(
      title: '24/7 Expert Support',
      description:
          'Round-the-clock premium support from VPN experts via live chat and email.',
      icon: Icons.support_agent,
      color: Colors.teal,
      benefit: 'Get help whenever you need it',
      details: 'Average response time under 2 minutes with expert technicians.',
    ),
    Feature(
      title: 'Zero-Logs Policy',
      description:
          'Independently audited no-logs policy ensures complete privacy and anonymity.',
      icon: Icons.visibility_off,
      color: Colors.indigo,
      benefit: 'Your activity stays private forever',
      details: 'Third-party audited by leading cybersecurity firms.',
    ),
    Feature(
      title: 'Advanced Malware Protection',
      description:
          'Built-in malware blocking, ad filtering, and tracker protection keeps you safe online.',
      icon: Icons.shield,
      color: Colors.red,
      benefit: 'Browse safely without ads or malware',
      details: 'Blocks 99.9% of malware, ads, and tracking attempts.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Stack(children: [_buildFloatingElements(), _buildContent()]),
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
        'Premium Features',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final random = math.Random(index);
            final size = 6.0 + random.nextDouble() * 8.0;
            final speed = 0.5 + random.nextDouble() * 1.0;
            final offset = random.nextDouble() * 2 * math.pi;

            final progress = (_floatingAnimation.value + offset) % 1.0;
            final x =
                MediaQuery.of(context).size.width *
                (0.1 + 0.8 * ((progress * speed) % 1.0));
            final y =
                MediaQuery.of(context).size.height *
                (0.1 + 0.8 * ((progress * speed * 0.7) % 1.0));

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.blue.withOpacity(0.4), Colors.transparent],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeroSection(),
                const SizedBox(height: 40),
                _buildStatsSection(),
                const SizedBox(height: 40),
                _buildFeaturesGrid(),
                const SizedBox(height: 40),
                _buildCTASection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Animated App Icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                height: 120.h,
                width: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/icons/icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 24.h),

        // Title with Gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.blue, Colors.purple, Colors.pink],
          ).createShader(bounds),
          child: Text(
            'Premium VPN Features',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 12.h),

        // Subtitle
        Text(
          'Advanced security and privacy features\nto protect your digital life',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.8),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.15),
            Colors.purple.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('99.9%', 'Uptime', Colors.green),
          _buildStatItem('256-bit', 'Encryption', Colors.blue),
          _buildStatItem('50+', 'Countries', Colors.purple),
          _buildStatItem('0', 'Logs Kept', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'What Makes Us Different',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...List.generate(_features.length, (index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 600 + (index * 100)),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * 30),
                child: Opacity(
                  opacity: value,
                  child: _buildEnhancedFeatureTile(_features[index], index),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildEnhancedFeatureTile(Feature feature, int index) {
    final isSelected = _selectedFeatureIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedFeatureIndex = isSelected ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              feature.color.withOpacity(isSelected ? 0.2 : 0.1),
              feature.color.withOpacity(isSelected ? 0.1 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: feature.color.withOpacity(isSelected ? 0.5 : 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: feature.color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Feature Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isSelected ? 60 : 50,
                    height: isSelected ? 60 : 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [feature.color, feature.color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: feature.color.withOpacity(0.4),
                          blurRadius: isSelected ? 15 : 10,
                          spreadRadius: isSelected ? 3 : 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      feature.icon,
                      color: Colors.white,
                      size: isSelected ? 30 : 24,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Feature Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSelected ? 20.sp : 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          feature.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse Indicator
                  AnimatedRotation(
                    turns: isSelected ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: feature.color,
                      size: 24,
                    ),
                  ),
                ],
              ),

              // Expanded Content
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: feature.color.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: feature.color, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature.benefit,
                              style: TextStyle(
                                color: feature.color,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature.details,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: isSelected
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ready to Get Protected?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Join millions of users who trust our VPN\nto protect their privacy and security',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16.sp,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // CTA Button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Get Premium Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Trust Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTrustIcon(Icons.security, 'Secure'),
              const SizedBox(width: 20),
              _buildTrustIcon(Icons.speed, 'Fast'),
              const SizedBox(width: 20),
              _buildTrustIcon(Icons.verified_user, 'Trusted'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class Feature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String benefit;
  final String details;

  Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.benefit,
    required this.details,
  });
}
