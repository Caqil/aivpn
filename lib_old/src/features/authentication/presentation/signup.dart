import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:safer_vpn/src/toast/flutter_styled_toast.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/index.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String name = "", email = "", password = "", passwordConfirmation = "";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _formkey = GlobalKey<FormState>();
  bool _obscuredText = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _registerNow(RoundedLoadingButtonController controller) async {
    AuthNotifier authProvider = Provider.of(context, listen: false);
    authProvider.signup(context, _btnController, name, email, password,
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
        builder: (context) => ConfirmAccount(email: email, password: password),
      ));
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
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                CupertinoIcons.arrow_left,
              ),
            ),
          ),
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  Lottie.asset(
                  //           'assets/lottie/wave.json',
                  //           height: size.height * 0.2,
                  //           width: size.width,
                  //           fit: BoxFit.fill,
                  //         ),
                  SizedBox(
                    height: size.height * 0.25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      'sign_up'.tr(),
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navLargeTitleTextStyle,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      'create_account'.tr(),
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          /// username
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: CupertinoTextFormFieldRow(
                                style: const TextStyle(color: Colors.white),
                                prefix: const Text('Username:'),
                                controller: namecontroller,
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'null';
                                  }
                                  return null;
                                },
                              )),
                          SizedBox(
                            height: size.height * 0.02,
                          ),

                          /// Gmail
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: CupertinoTextFormFieldRow(
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                controller: mailcontroller,
                                decoration: const BoxDecoration(),
                                prefix: const Text('Email:'),
                                validator: (value) {
                                  if (validateEmail(value) != null) {
                                    _btnController.reset();
                                    return 'Please Enter Email';
                                  }
                                  return null;
                                },
                              )),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: CupertinoTextFormFieldRow(
                                style: const TextStyle(color: Colors.white),
                                prefix: Text('password'.tr()),
                                controller: passwordcontroller,
                                obscureText: _obscuredText,
                                // decoration: InputDecoration(
                                //   prefixIcon: const Icon(Icons.lock_open),
                                //   suffixIcon: IconButton(
                                //       icon: Icon(
                                //         !_obscuredText
                                //             ? Icons.visibility
                                //             : Icons.visibility_off,
                                //       ),
                                //       onPressed: _toggle),
                                //   hintText: 'Password',
                                // ),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  } else if (value.length < 7) {
                                    return 'at least enter 6 characters';
                                  } else if (value.length > 13) {
                                    return 'maximum character is 13';
                                  }
                                  return null;
                                },
                              )),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'okay_with'.tr(),
                                  style: const TextStyle(
                                      color: CupertinoColors.white),
                                ),
                                TextSpan(
                                  text: 'terms_services'.tr(),
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse(
                                          'https://docs.flutter.io/flutter/services/UrlLauncher-class.html'));
                                    },
                                ),
                                const TextSpan(
                                  text: ' & ',
                                  style: TextStyle(),
                                ),
                                TextSpan(
                                  text: 'privacy_policy'.tr(),
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse(
                                          'https://docs.flutter.io/flutter/services/UrlLauncher-class.html'));
                                    },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          SizedBox(
                            height: size.height * 0.03,
                          ),

                          RoundedLoadingButton(
                            controller: _btnController,
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  name = namecontroller.text;
                                  email = mailcontroller.text;
                                  password = passwordcontroller.text;
                                });
                              }
                              _registerNow(_btnController);
                            },
                            valueColor: CupertinoColors.black,
                            borderRadius: 10,
                            child: Text("sign_up".tr(),
                                style: TextStyle(fontSize: 18.0)),
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (ctx) => const Login()));
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'already_have_account'.tr(),
                                style: TextStyle(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.systemGrey,
                                ),
                                children: [
                                  TextSpan(
                                    text: "login".tr(),
                                    style: TextStyle(
                                      fontSize: size.height * 0.020,
                                      fontWeight: FontWeight.w500,
                                      color: CupertinoColors.systemPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
