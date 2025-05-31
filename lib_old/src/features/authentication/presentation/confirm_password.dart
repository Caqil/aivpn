import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safer_vpn/src/toast/flutter_styled_toast.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../../constants/index.dart';

class ConfirmPassword extends StatefulWidget {
  final String? email;
  const ConfirmPassword({super.key, this.email});

  @override
  State<ConfirmPassword> createState() => _ConfirmPasswordState();
}

class _ConfirmPasswordState extends State<ConfirmPassword> {
  String newPassword = "", verificationCode = "";
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController verficationCodeController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _formkey = GlobalKey<FormState>();
  bool _obscuredText = true;
  _toggle() {
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _resetNow(RoundedLoadingButtonController controller) async {
    AuthNotifier authProvider = Provider.of(context, listen: false);
    authProvider.confirmResetPassword(
        context, controller, widget.email, newPassword, verificationCode,
        onSuccess: (success) {
      showToast(
        success,
        backgroundColor: CupertinoColors.activeGreen,
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: StyledToastPosition.center,
        animDuration: Duration(seconds: 1),
        duration: Duration(seconds: 4),
        curve: Curves.elasticOut,
        reverseCurve: Curves.linear,
      );

      navigatorKey.currentState!.pushReplacement(
          CupertinoPageRoute(builder: (context) => const Login()));
    }, onError: (error) {
      showToast(
        error,
        backgroundColor: CupertinoColors.systemRed,
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: StyledToastPosition.center,
        animDuration: Duration(seconds: 1),
        duration: Duration(seconds: 4),
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
            title: Text(
              "password_recovery".tr(),
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                controller: newPasswordController,
                                prefix: Text('new_password'.tr()),
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
                                style: TextStyle(color: Colors.white),
                                prefix: Text('verification_code'.tr()),
                                controller: verficationCodeController,
                              )),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          RoundedLoadingButton(
                            color: CupertinoTheme.of(context).primaryColor,
                            controller: _btnController,
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  newPassword = newPasswordController.text;
                                  verificationCode =
                                      verficationCodeController.text;
                                  _btnController.reset();
                                });
                              }
                              _resetNow(_btnController);
                            },
                            valueColor: CupertinoColors.black,
                            borderRadius: 10,
                            child: Text("reset_now".tr(),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                )),
                          ),
                          SizedBox(
                            height: size.height * 0.02,
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
