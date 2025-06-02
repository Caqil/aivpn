import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  final List<Feature> _features = [
    Feature(
      title: 'Torrenting Support',
      description:
          'Optimized servers for safe and fast torrenting with unlimited bandwidth.',
    ),
    Feature(
      title: 'DNS Leak Protection',
      description:
          'Ensures that your DNS requests are routed through the VPN tunnel.',
    ),
    Feature(
      title: 'Automatic WiFi Protection',
      description:
          'Automatically activates VPN when connecting to unsecured WiFi networks.',
    ),
    Feature(
      title: 'Simultaneous Connections',
      description:
          'Connect multiple devices simultaneously with a single account.',
    ),
    Feature(
      title: '24/7 Customer Support',
      description:
          'Offers round-the-clock customer support for any issues or questions.',
    ),
    Feature(
      title: 'No Logs Policy',
      description: 'Guarantees complete privacy with a strict no-logs policy.',
    ),
    Feature(
      title: 'Malware Protection',
      description: 'Built-in malware and ad blocking to keep your device safe.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('VPN Special Features', style: TextStyle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Icon
            SizedBox.fromSize(
              size: const Size.fromRadius(48),
              child: Image.asset(
                'assets/icons/icon.png',
                fit: BoxFit.cover,
                height: 100.h,
              ),
            ),
            const SizedBox(height: 20),

            // Features List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _features.map((feature) {
                  return _buildFeatureTile(feature);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(Feature feature) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.security, color: Colors.blue),
        ),
        title: Text(
          feature.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            feature.description,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class Feature {
  final String title;
  final String description;

  Feature({required this.title, required this.description});
}
