import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class ToastBar {
  static Color _setBackgroundColor(ToastType type, BuildContext context) {
    switch (type) {
      case ToastType.success:
        return Theme.of(context).colorScheme.primary;
      case ToastType.error:
        return Theme.of(context).colorScheme.error;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static Color _setTextColor(ToastType type, BuildContext context) {
    switch (type) {
      case ToastType.success:
        return Theme.of(context).colorScheme.onSecondary;
      case ToastType.error:
        return Theme.of(context).colorScheme.onError;
      default:
        return Colors.white;
    }
  }

  static void show({
    required BuildContext context,
    required ToastType type,
    required String message,
  }) {
    final snackBar = ScaffoldMessenger.of(context);

    snackBar
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: _setBackgroundColor(type, context),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'ComicNeue',
              color: _setTextColor(type, context),
            ),
          ),
        ),
      );
  }
}
