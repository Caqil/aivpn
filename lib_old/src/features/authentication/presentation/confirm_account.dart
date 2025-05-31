import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safer_vpn/src/toast/flutter_styled_toast.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:safer_vpn/src/features/authentication/infrastructure/auth_notifier.dart';
import 'package:safer_vpn/src/pages/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class ConfirmAccount extends StatefulWidget {
  final String? email;
  final String? password;
  const ConfirmAccount({super.key, this.email, this.password});

  @override
  State<ConfirmAccount> createState() => _ConfirmAccountState();
}

class _ConfirmAccountState extends State<ConfirmAccount> {
  String code = "";
  TextEditingController codeController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _formkey = GlobalKey<FormState>();
  bool hasError = false;
  User? user;
  void _confirmNow(RoundedLoadingButtonController controller) async {
    AuthNotifier authProvider = Provider.of(context, listen: false);
    authProvider.confirmAccount(context, _btnController, widget.email!, code,
        onSuccess: (success) {
      showToast(
        success,
        backgroundColor: CupertinoColors.activeGreen,
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: StyledToastPosition.center,
        animDuration: const Duration(seconds: 1),
        duration: const Duration(seconds: 4),
        curve: Curves.elasticOut,
        reverseCurve: Curves.linear,
      );

      navigatorKey.currentState!.pushAndRemoveUntil(
        CupertinoPageRoute(
          builder: (_) {
            return const SplashPage();
          },
        ),
        (route) => false,
      );
    }, onError: (error) {
      showToast(
        error,
        backgroundColor: CupertinoColors.systemRed,
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: StyledToastPosition.center,
        animDuration: const Duration(seconds: 1),
        duration: const Duration(seconds: 4),
        curve: Curves.elasticOut,
        reverseCurve: Curves.linear,
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _skipNow() async {
    navigatorKey.currentState!.pushReplacement(CupertinoPageRoute(
      builder: (context) => const SplashPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        GestureDetector(
          onTap: _skipNow,
          child: Text(
            'Skip',
            style: TextStyle(
                decoration: TextDecoration.underline, fontSize: 18.sp),
          ),
        ),
      ]),
      body: Column(
        children: [
          const SizedBox(
            height: 70.0,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Text(
              "verification_account".tr(),
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            "enter_verification".tr(namedArgs: {'email': widget.email!}),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: Form(
                  key: _formkey,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ListView(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: CupertinoTextFormFieldRow(
                                style: TextStyle(color: Colors.white),
                                prefix: Text('verification_code'.tr()),
                                controller: codeController,
                              )),

                          //  TextFormField(
                          //   keyboardType: TextInputType.number,
                          //   validator: (value) {
                          //     if (value!.isEmpty) {
                          //       _btnController.reset();
                          //       return 'Please Enter Verification Code';
                          //     }
                          //     return null;
                          //   },
                          //   controller: codeController,
                          //   decoration: const InputDecoration(
                          //       contentPadding: EdgeInsets.symmetric(
                          //           vertical: 1.0, horizontal: 10.0),
                          //       hintText: "Code",
                          //       hintStyle: TextStyle(
                          //           fontSize: 18.0, color: Colors.grey),
                          //       prefixIcon: Icon(
                          //         Icons.mail,
                          //         color: Colors.white70,
                          //         size: 30.0,
                          //       ),
                          //       border: InputBorder.none),
                          // ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        RoundedLoadingButton(
                          color: CupertinoTheme.of(context).primaryColor,
                          controller: _btnController,
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                code = codeController.text;
                                _btnController.reset();
                              });
                            }
                            _confirmNow(_btnController);
                          },
                          valueColor: CupertinoColors.black,
                          borderRadius: 10,
                          child: Text("verification_now".tr(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                              )),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                      ],
                    ),
                  ))),
        ],
      ),
    );
  }
}
