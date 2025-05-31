import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/subscription_page/purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    AuthNotifier userNotifier = Provider.of(context, listen: false);
    userNotifier.getProfiles(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Platform.isMacOS ? false : true,
        actions: [
          Platform.isMacOS
              ? Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close)))
              : const SizedBox.shrink()
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? buildPortraitLayout()
              : buildLandscapeLayout();
        },
      ),
    );
  }

  Widget buildPortraitLayout() {
    AuthNotifier userNotifier = Provider.of(context, listen: false);
    userNotifier.getProfiles(context);
    return SingleChildScrollView(
        child: Stack(children: [
      SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 150,
                      width: 150,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/icons/icon.png'),
                              fit: BoxFit.cover))),
                  Text('try_vpn_premium'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 20.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('protects_your_privacy'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 5.h),
                      Text('indulge_streaming'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 5.h),
                      Text('securely_access'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 5.h),
                      Text('virtual_locations.'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 5.h),
                      Text('no_ads'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 5.h),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  const PurchaseWidget(),
                  SizedBox(height: 10.h),
                  SizedBox(height: 10.h),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Your_subscription_will'.tr(),
                          style: const TextStyle(color: CupertinoColors.white),
                        ),
                        TextSpan(
                          text: 'terms_services'.tr(),
                          style: const TextStyle(
                              color: CupertinoColors.systemBlue,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(urlTerms));
                            },
                        ),
                        const TextSpan(
                          text: ' & ',
                          style: TextStyle(),
                        ),
                        TextSpan(
                          text: 'privacy_policy'.tr(),
                          style: const TextStyle(
                              color: CupertinoColors.systemBlue,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(urlPrivacy));
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                      onTap: () {
                        InAppPurchase.instance.restorePurchases(
                            applicationUserName: userNotifier.user.email);
                      },
                      child: Text(
                        'restore'.tr(),
                        style: const TextStyle(
                            decoration: TextDecoration.underline),
                      ))
                ],
              ),
            )),
      )
    ]));
  }

  Widget buildLandscapeLayout() {
    AuthNotifier userNotifier = Provider.of(context, listen: false);
    userNotifier.getProfiles(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: Platform.isMacOS ? 70 : 150,
                              width: Platform.isMacOS ? 70 : 150,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          AssetImage('assets/icons/icon.png'),
                                      fit: BoxFit.cover))),
                          Text('try_vpn_premium'.tr(),
                              style: Theme.of(context).textTheme.bodyLarge),
                          SizedBox(height: 20.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('protects_your_privacy'.tr(),
                                  style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 5.h),
                              Text('indulge_streaming'.tr(),
                                  style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 5.h),
                              Text('securely_access'.tr(),
                                  style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 5.h),
                              Text('virtual_locations.'.tr(),
                                  style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 5.h),
                              Text('no_ads'.tr(),
                                  style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 5.h),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          GestureDetector(
                              onTap: () {
                                InAppPurchase.instance.restorePurchases(
                                    applicationUserName:
                                        userNotifier.user.email);
                              },
                              child: Text(
                                'restore'.tr(),
                                style: const TextStyle(
                                    decoration: TextDecoration.underline),
                              ))
                        ],
                      ),
                    )),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PurchaseWidget(),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Your_subscription_will'.tr(),
                            style:
                                const TextStyle(color: CupertinoColors.white),
                          ),
                          TextSpan(
                            text: 'terms_services'.tr(),
                            style: const TextStyle(
                                color: CupertinoColors.systemBlue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse(urlTerms));
                              },
                          ),
                          const TextSpan(
                            text: ' & ',
                            style: TextStyle(),
                          ),
                          TextSpan(
                            text: 'privacy_policy'.tr(),
                            style: const TextStyle(
                                color: CupertinoColors.systemBlue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse(urlPrivacy));
                              },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
