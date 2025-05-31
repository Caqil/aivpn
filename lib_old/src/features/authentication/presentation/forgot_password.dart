import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safer_vpn/src/toast/flutter_styled_toast.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../../constants/index.dart';

class ForgotPassword extends StatefulWidget {
  static String routeName = '/forgot';
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = "";
  TextEditingController mailcontroller = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _formkey = GlobalKey<FormState>();
  void _resetNow(RoundedLoadingButtonController controller) async {
    AuthNotifier authProvider = Provider.of(context, listen: false);
    authProvider.forgotPassword(context, _btnController, email,
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

      navigatorKey.currentState!.pushReplacement(CupertinoPageRoute(
          builder: (context) => ConfirmPassword(email: email)));
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 70.0,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Text(
              "password_recovery".tr(),
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            "enter_mail".tr(),
            style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: Form(
                  key: _formkey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ListView(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: CupertinoColors.systemGrey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: CupertinoTextFormFieldRow(
                            style: TextStyle(color: Colors.white),
                            prefix: const Text('Email:'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (validateEmail(value) != null) {
                                _btnController.reset();
                                return 'Please Enter E-mail';
                              }
                              return null;
                            },
                            controller: mailcontroller,
                          ),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        RoundedLoadingButton(
                          controller: _btnController,
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = mailcontroller.text;
                              });
                            }
                            _resetNow(_btnController);
                          },
                          valueColor: CupertinoColors.black,
                          borderRadius: 10,
                          child: Text("get_code".tr(),
                              style: TextStyle(
                                fontSize: 18.0,
                              )),
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     if (_formkey.currentState!.validate()) {
                        //       setState(() {
                        //         email = mailcontroller.text;
                        //       });
                        //       authProvider.forgotPassword(context, email);
                        //     }
                        //   },
                        //   child: Container(
                        //     width: 140,
                        //     padding: const EdgeInsets.all(10),
                        //     decoration: BoxDecoration(
                        //         color: kPrimaryColor,
                        //         borderRadius: BorderRadius.circular(10)),
                        //     child: const Center(
                        //       child: Text(
                        //         "Send Email",
                        //         style: TextStyle(
                        //             color: Colors.black,
                        //             fontSize: 18.0,
                        //             fontWeight: FontWeight.bold),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 50.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "dont_have_account".tr(),
                              style: TextStyle(
                                  fontSize: 18.0, color: CupertinoColors.white),
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen()));
                              },
                              child: Text(
                                "create".tr(),
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ))),
        ],
      ),
    );
  }
}
