import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:safer_vpn/src/constants/toast_snackbar.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier with ChangeNotifier {
  late User _user;
  User get user => _user;
  String get token => userToken;
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<User?> signup(
    BuildContext context,
    RoundedLoadingButtonController controller,
    String name,
    String email,
    String password, {
    Function? onSuccess,
    Function? onError,
  }) async {
    if (name.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    if (email.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    if (password.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    final response = await http.post(
      Uri.parse(Apis.signUpApi),
      headers: {'Accept': 'application/json'},
      body: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password
      },
    );
    var data = jsonDecode(response.body);
    String infoUser = data['message'];
    if (response.statusCode == HttpStatus.ok) {
      controller.reset();
      userToken = data['data']['api_token'];
      saveUserToken(token);
      navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
        builder: (context) => ConfirmAccount(email: email),
      ));
      _user = User.fromJson(data);
      return _user;
    } else {
      if (context.mounted) {
        ToastBar.show(
            message: infoUser, type: ToastType.error, context: context);
      }
      onError?.call(data['message']);
      controller.reset();
    }
    notifyListeners();
    return _user;
  }

  Future<User> confirmAccount(
    BuildContext context,
    RoundedLoadingButtonController controller,
    String email,
    String code, {
    Function? onSuccess,
    Function? onError,
  }) async {
    if (email.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }

    if (code.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    final response = await http.post(Uri.parse(Apis.confirmAccountApi),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'verification_code': code});
    var data = jsonDecode(response.body);
    controller.start();
    String infoUser = data['message'];
    if (response.statusCode == HttpStatus.ok) {
      controller.success();
      if (context.mounted) {
        navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (context) => const SplashPage()));
      }
      _user = User.fromJson(json.decode(data['data']));
      return _user;
    } else {
      ToastBar.show(context: context, message: infoUser, type: ToastType.error);
      controller.reset();
      onError?.call();
    }
    notifyListeners();
    return _user;
  }

  Future<User?> login(
    BuildContext context,
    RoundedLoadingButtonController controller,
    String email,
    String password, {
    Function? onSuccess,
    Function? onError,
  }) async {
    if (email.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    if (password.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
    };
    controller.start();
    final response = await http.post(
      Uri.parse(Apis.loginApi),
      headers: requestHeaders,
      body: {"email": email, "password": password},
    );
    var data = jsonDecode(response.body);
    if (response.statusCode == HttpStatus.ok) {
      userToken = data['data']['token'];
      saveUserToken(token);
      navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashPage()));
      _user = User.fromJson(data);
      notifyListeners();
      controller.reset();
      return _user;
    } else {
      controller.reset();
      if (context.mounted) {
        ToastBar.show(
            context: context, message: data['message'], type: ToastType.error);
      }
    }
    return null;
  }

  Future<User> forgotPassword(
    BuildContext context,
    RoundedLoadingButtonController controller,
    String email, {
    Function? onSuccess,
    Function? onError,
  }) async {
    if (email.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }

    final response = await http.post(Uri.parse(Apis.forgotPasswordApi),
        headers: {'Accept': 'application/json'}, body: {'email': email});
    controller.start();
    var data = jsonDecode(response.body);
    if (response.statusCode == HttpStatus.ok) {
      navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (context) => const ForgotPassword()));
      _user = User.fromJson(data);
      if (context.mounted) {
        ToastBar.show(
            context: context,
            message: data['message'],
            type: ToastType.success);
      }
      return _user;
    } else {
      if (context.mounted) {
        ToastBar.show(
            context: context, message: data['message'], type: ToastType.error);
      }
      controller.error();
      onError?.call();
    }
    notifyListeners();
    controller.reset();
    return _user;
  }

  Future<User> confirmResetPassword(
    BuildContext context,
    RoundedLoadingButtonController controller,
    String? email,
    String? password,
    String? verificationCode, {
    Function? onSuccess,
    Function? onError,
  }) async {
    if (email!.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    if (password!.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    if (verificationCode!.isEmpty) {
      ToastBar.show(
          type: ToastType.error,
          context: context,
          message: "Missing Information!");
      controller.reset();
    }
    final response = await http.post(
      Uri.parse(Apis.confirmResetPasswordApi),
      headers: {'Accept': 'application/json'},
      body: {
        "email": email,
        "new_password": password,
        "new_password_confirmation": password,
        "verification_code": verificationCode
      },
    );
    var data = jsonDecode(response.body);
    controller.start();
    if (response.statusCode == HttpStatus.ok) {
      controller.reset();
      _user = User.fromJson(data);
      navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()));
      notifyListeners();
      if (context.mounted) {
        ToastBar.show(
            context: context, message: data['message'], type: ToastType.error);
      }
      return _user;
    } else {
      controller.error();
      onError?.call();
    }
    notifyListeners();
    return _user;
  }

  Future<User?> deleteUser(
    BuildContext context,
    int id, {
    Function? onSuccess,
    Function? onError,
  }) async {
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
      'X-Api-Key':
          '06RhtKyQB5BxdGOFaHhysy3jx1eZQ23fS56FH3dIKStdskaO4nyLvqOoH5ok8zem'
    };
    var response = await http.delete(
      Uri.parse("${Apis.deleteProfilesApi} + $id"),
      headers: requestHeaders,
    );
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (context.mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Login()));
        deleteToken();
        ToastBar.show(
            type: ToastType.success,
            context: context,
            message: data['message']);
      }
    } else {
      if (context.mounted) {
        ToastBar.show(
            type: ToastType.error, context: context, message: data['message']);
      }
    }
    return null;
  }

  Future<User?> getProfiles(
    BuildContext context, {
    Function? onSuccess,
    Function? onError,
  }) async {
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken'
    };
    final response = await http.get(
      Uri.parse(Apis.profilesApi),
      headers: requestHeaders,
    );
    var data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.ok) {
      _user = User.fromJson(data['data']);
      setUser(_user);
      notifyListeners();
      return _user;
    } else if (response.statusCode == HttpStatus.unauthorized) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
      onError?.call();
    } else {
      onError?.call();
    }
    return user;
  }

  Future<User> updateProfiles(
    BuildContext context,
    String? userName,
    String? firstname,
    String? lastname, {
    Function? onSuccess,
    Function? onError,
  }) async {
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken'
    };
    final response = await http.post(Uri.parse(Apis.profilesApi),
        headers: requestHeaders,
        body: {"name": userName, "firstname": firstname, "lastname": lastname});
    var data = jsonDecode(response.body);
    if (response.statusCode == HttpStatus.ok) {
      _user = User.fromJson(data);
      notifyListeners();
      return _user;
    }
    notifyListeners();
    return _user;
  }

  Future<void> saveUserToken(userToken) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userToken', userToken);
  }

  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<String?> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userToken');
    return null;
  }

  void deleteToken() async {
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userToken');
  }

  Future<void> checkToken() async {
    final token = await getUserToken();
    if (token != null || token!.isNotEmpty) {
      _isAuthenticated = true;
      userToken = token;
      notifyListeners();
    } else {
      _isAuthenticated = false;
      userToken = '';
      notifyListeners();
    }
  }

  void setUser(User userModel) {
    _user = userModel;
    notifyListeners();
  }

  // Getter method to access _data
  User getUser() {
    return _user;
  }

  static AuthNotifier read(BuildContext context) => context.read();
  static AuthNotifier watch(BuildContext context) => context.watch();
}
