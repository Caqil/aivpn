import 'dart:io';
import 'package:flutter/foundation.dart';

class AdManager extends ChangeNotifier {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/6300978111';
      return 'ca-app-pub-4723559548771200/6635374034';
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/2934735716';
      return 'ca-app-pub-4723559548771200/2273101972';
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialConnectAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712';
      return 'ca-app-pub-4723559548771200/2696129020';
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/4411468910';
      return 'ca-app-pub-4723559548771200/7254321137';
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialDisconnectAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712';
      return 'ca-app-pub-4723559548771200/9736659024';
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/4411468910';
      return 'ca-app-pub-4723559548771200/9425188900';
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialServerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712';
      return 'ca-app-pub-4723559548771200/9736659024';
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/4411468910';
      return 'ca-app-pub-4723559548771200/9425188900';
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/5224354917';
      return 'ca-app-pub-4723559548771200/8371606461';
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/1712485313';
      return 'ca-app-pub-4723559548771200/9688912780';
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/9257395921';
      return 'ca-app-pub-4723559548771200/7645203377';
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/5575463023';
      return 'ca-app-pub-4723559548771200/7333856962';
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
