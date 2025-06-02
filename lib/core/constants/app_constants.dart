import 'dart:io';

class AppConstants {
  // App Info
  static const String appName = '360 AI VPN';
  static const String contactEmail = 'support@billiongroup.net';
  static const String appStoreId = '6497651476';

  // URLs
  static const String privacyUrl =
      'https://firebasestorage.googleapis.com/v0/b/sec-vpn-524ac.appspot.com/o/privacy_360.html?alt=media';
  static const String termsUrl =
      'https://firebasestorage.googleapis.com/v0/b/sec-vpn-524ac.appspot.com/o/term_360.html?alt=media';

  // Store URLs
  static String get storeUrl => Platform.isIOS
      ? 'https://apps.apple.com/id/app/360-ai-vpn/id6497651476'
      : 'https://play.google.com/store/apps/details?id=com.fast.aivpn360';

  // Product IDs
  static String get monthlyProductId => Platform.isIOS || Platform.isMacOS
      ? 'monthly_360'
      : 'monthly_360_android';

  static String get yearlyProductId =>
      Platform.isIOS || Platform.isMacOS ? 'yearly_360' : 'yearly_360_android';

  // API Constants (from existing file)
  static const String baseUrl = 'https://dash.bgtunnel.com';
  static const String serversEndpoint = '/api/servers';
  static const String apiToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjYWtyNCIsImFjY2VzcyI6InN1ZG8iLCJpYXQiOjE3NDY4NDkwNzUsImV4cCI6MjY5MjkyOTA3NX0.7QLWKHftA8XD9QIPNaryEY6svl5uZ00mcvIkZ2AITZw';

  // Connection timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // AdMob IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4723559548771200/6635374034';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4723559548771200/2273101972';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4723559548771200/2696129020';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4723559548771200/7254321137';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4723559548771200/8371606461';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4723559548771200/9688912780';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4723559548771200/7645203377';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4723559548771200/7333856962';
    }
    throw UnsupportedError("Unsupported platform");
  }

  // Test Ad IDs (for debug mode)
  static String get testBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get testInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get testRewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get testAppOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9257395921';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5575463023';
    }
    throw UnsupportedError("Unsupported platform");
  }
}
