import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safer_vpn/src/toast/flutter_styled_toast.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:safer_vpn/src/pages/index.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "";
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _obscuredText = true;
  final _formkey = GlobalKey<FormState>();
  Logs? userLogs;
  _toggle() {
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }

  void _loginNow(mail, password) async {
    AuthNotifier authProvider = Provider.of(context, listen: false);
    authProvider.login(context, _btnController, email, password,
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.25,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        'login'.tr(),
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
                        'Welcome Back'.tr(namedArgs: {'appName': appName}),
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
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: CupertinoTextFormFieldRow(
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                controller: mailcontroller,
                                prefix: const Text('Email:'),
                                validator: (value) {
                                  if (validateEmail(value) != null) {
                                    _btnController.reset();
                                    return 'Please Enter Email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      _btnController.reset();
                                      return 'Please enter some text';
                                    } else if (value.length < 7) {
                                      return 'at least enter 6 characters';
                                    }
                                    return null;
                                  },
                                )),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            RoundedLoadingButton(
                              controller: _btnController,
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    email = mailcontroller.text;
                                    password = passwordcontroller.text;
                                  });
                                  _loginNow(mailcontroller.text,
                                      passwordcontroller.text);
                                }
                              },
                              valueColor: CupertinoColors.black,
                              borderRadius: 10,
                              child: Text("login".tr(),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  )),
                            ),
                            SizedBox(
                              height: size.height * 0.03,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const ForgotPassword()));
                                _formkey.currentState?.reset();
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'forgot_password'.tr(),
                                  style: TextStyle(
                                      fontSize: size.height * 0.017,
                                      color: CupertinoColors.destructiveRed,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.03,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen()));
                                _formkey.currentState?.reset();
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'dont_have_account'.tr(),
                                  style: TextStyle(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "sign_up".tr(),
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
                )
              ],
            )),
      ),
    );
  }
}
