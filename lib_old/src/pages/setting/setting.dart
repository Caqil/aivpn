import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/features/features.dart';
import 'package:safer_vpn/src/pages/language/language.dart';
import 'package:safer_vpn/src/pages/splash_page/presentation/privacy.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  final User user;
  const Settings({super.key, required this.user});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void redirectToSignIn() {
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (_) {
          return const Privacy();
        },
      ),
      (route) => false,
    );
  }

  void onSignOut() {
    redirectToSignIn();
    Provider.of<AuthNotifier>(context, listen: false).signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "settings".tr(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.person),
                SizedBox(width: 8.w),
                Text(
                  "account".tr(),
                  style: TextStyle(
                      fontSize: Platform.isMacOS ? 6.sp : 18.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            buildAccountOptionRow(context, "Email",
                trailing: Text(
                  widget.user.email!,
                  style: TextStyle(
                      color: widget.user.emailVerifiedAt == null
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemBlue),
                )),
            buildAccountOptionRow(context, "plan".tr(),
                trailing: !widget.user.subscription!.expiryAt!
                        .isBefore(DateTime.now())
                    ? Text(
                        widget.user.subscription!.plan!.name!,
                        style: TextStyle(
                            fontSize: Platform.isMacOS ? 8.sp : 10.sp,
                            color: const Color.fromARGB(255, 18, 243, 2)),
                      )
                    : Text(
                        "Free Plan",
                        style: TextStyle(
                            fontSize: Platform.isMacOS ? 6.sp : 10.sp,
                            color: const Color.fromARGB(255, 243, 2, 2)),
                      )),
            SizedBox(
              height: 30.h,
            ),
            Row(
              children: [
                Icon(
                  CupertinoIcons.escape,
                  size: Platform.isMacOS ? 20 : 40,
                ),
                SizedBox(
                  width: 8.w,
                ),
                Text(
                  "common".tr(),
                  style: TextStyle(
                      fontSize: Platform.isMacOS ? 6.sp : 18.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            buildAccountOptionRow(
              context,
              "languages".tr(),
              onTap: () async {
                if (Platform.isMacOS) {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                          height: double.maxFinite,
                          width: 400,
                          color: Colors.white,
                          child: const LanguagesPage());
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const LanguagesPage()),
                  );
                }
              },
            ),
            buildAccountOptionRow(
              context,
              "vpn_special_features".tr(),
              onTap: () async {
                if (Platform.isMacOS) {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                          height: double.maxFinite,
                          width: 400,
                          color: Colors.white,
                          child: const FeaturesPage());
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const FeaturesPage()),
                  );
                }
              },
            ),
            buildAccountOptionRow(
              context,
              "share".tr(),
              onTap: () async {
                Share.share(
                    '360 AI VPN protects your privacy ${Platform.isIOS ? "https://apps.apple.com/id/app/360-ai-vpn/id6497651476" : "https://play.google.com/store/apps/details?id=com.fast.aivpn360"}');
              },
            ),
            buildAccountOptionRow(
              context,
              "privacy_policy".tr(),
              onTap: () async {
                await launchUrl(Uri.parse(urlPrivacy));
              },
            ),
            buildAccountOptionRow(
              context,
              "terms_services".tr(),
              onTap: () async {
                await launchUrl(Uri.parse(urlTerms));
              },
            ),
            buildAccountOptionRow(
              context,
              "contactus".tr(),
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: contactEmail,
                  query: encodeQueryParameters(<String, String>{
                    'Contact': 'Example Subject & Symbols are allowed!',
                  }),
                );
                if (!await launchUrl(emailLaunchUri)) {
                  throw 'Could not launch $emailLaunchUri';
                }
              },
            ),
            SizedBox(
              height: 30.h,
            ),
            buildAccountOptionRow(
              context,
              "logout".tr(),
              onTap: () {
                onSignOut();
              },
            ),
            Center(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                onPressed: () {
                  showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                            title: Text('delete_account'.tr()),
                            content: Text(
                              "delete_account_desc".tr(),
                              textAlign: TextAlign.start,
                            ),
                            actions: [
                              CupertinoButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: Text('cancel'.tr()),
                              ),
                              CupertinoButton(
                                onPressed: () {
                                  AuthNotifier authProvider =
                                      Provider.of(context, listen: false);
                                  authProvider.deleteUser(
                                      context, widget.user.id!);
                                },
                                child: Text(
                                  'delete_now'.tr(),
                                  style: const TextStyle(
                                      color: CupertinoColors.systemRed),
                                ),
                              ),
                            ],
                          ));
                },
                child: Text("delete_account".tr(),
                    style: TextStyle(
                        fontSize: Platform.isMacOS ? 8.sp : 16.sp,
                        color: CupertinoColors.systemRed,
                        letterSpacing: 2.2)),
              ),
            )
          ],
        ),
      ),
    );
  }

  GestureDetector buildAccountOptionRow(BuildContext context, String title,
      {Function()? onTap, Widget? trailing}) {
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            )));
  }
}
