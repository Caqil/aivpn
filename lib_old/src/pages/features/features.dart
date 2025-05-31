import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({super.key});

  @override
  State<FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'vpn_special_features'.tr(),
          style: const TextStyle(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox.fromSize(
              size: const Size.fromRadius(48),
              child: Image.asset(
                'assets/icons/ic_icon.png',
                fit: BoxFit.cover,
                height: 100.h,
              ),
            ),
            ListTile(
              title: Text(
                'torrenting_support'.tr(),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'optimized_servers'.tr(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            ListTile(
              title: Text(
                'dns_leak_protection'.tr(),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'ensures_that'.tr(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            ListTile(
              title: Text(
                'automatic_wifi'.tr(),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'automatically_activates'.tr(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            ListTile(
              title: Text(
                'simultaneous_connections'.tr(),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'multiple_devices'.tr(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            ListTile(
              title: Text(
                'customer_support'.tr(),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'offers_round'.tr(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            ListTile(
              title: Text(
                'no_logs'.tr(),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'guarantees'.tr(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            ListTile(
              title: Text(
                'malware_protection'.tr(),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'malware_protection_desc'.tr(),
                style: const TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }
}
