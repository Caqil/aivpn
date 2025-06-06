// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import '../constants/app_constants.dart';

// class AdMobService {
//   static AdMobService? _instance;
//   static AdMobService get instance => _instance ??= AdMobService._();
//   AdMobService._();

//   static BannerAd? _bannerAd;
//   static InterstitialAd? _interstitialAd;
//   static RewardedAd? _rewardedAd;
//   static AppOpenAd? _appOpenAd;
//   static bool _isShowingAd = false;

//   static void initialize() {
//     MobileAds.instance.initialize();
//   }

//   static String _getBannerAdUnitId() {
//     return kDebugMode
//         ? AppConstants.testBannerAdUnitId
//         : AppConstants.bannerAdUnitId;
//   }

//   static String _getInterstitialAdUnitId() {
//     return kDebugMode
//         ? AppConstants.testInterstitialAdUnitId
//         : AppConstants.interstitialAdUnitId;
//   }

//   static String _getRewardedAdUnitId() {
//     return kDebugMode
//         ? AppConstants.testRewardedAdUnitId
//         : AppConstants.rewardedAdUnitId;
//   }

//   static String _getAppOpenAdUnitId() {
//     return kDebugMode
//         ? AppConstants.testAppOpenAdUnitId
//         : AppConstants.appOpenAdUnitId;
//   }

//   static void createBannerAd() {
//     _bannerAd = BannerAd(
//       adUnitId: _getBannerAdUnitId(),
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (Ad ad) => debugPrint('Banner Ad Loaded'),
//         onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           ad.dispose();
//           debugPrint('Banner Ad Failed to Load: $error');
//         },
//         onAdOpened: (Ad ad) => debugPrint('Banner Ad Opened'),
//         onAdClosed: (Ad ad) => debugPrint('Banner Ad Closed'),
//       ),
//     )..load();
//   }

//   static Widget showBannerAd() {
//     if (_bannerAd != null) {
//       return Container(
//         width: _bannerAd!.size.width.toDouble(),
//         height: _bannerAd!.size.height.toDouble(),
//         alignment: Alignment.center,
//         child: AdWidget(ad: _bannerAd!),
//       );
//     } else {
//       return const SizedBox.shrink();
//     }
//   }

//   static void createInterstitialAd() {
//     InterstitialAd.load(
//       adUnitId: _getInterstitialAdUnitId(),
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (InterstitialAd ad) {
//           _interstitialAd = ad;
//           _interstitialAd!.fullScreenContentCallback =
//               FullScreenContentCallback(
//                 onAdShowedFullScreenContent: (InterstitialAd ad) =>
//                     debugPrint('Interstitial Ad Showed'),
//                 onAdDismissedFullScreenContent: (InterstitialAd ad) {
//                   ad.dispose();
//                   createInterstitialAd();
//                 },
//                 onAdFailedToShowFullScreenContent:
//                     (InterstitialAd ad, AdError error) {
//                       ad.dispose();
//                       createInterstitialAd();
//                       debugPrint('Interstitial Ad Failed to Show: $error');
//                     },
//               );
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           debugPrint('Interstitial Ad Failed to Load: $error');
//         },
//       ),
//     );
//   }

//   static void showInterstitialAd() {
//     if (_interstitialAd != null) {
//       _interstitialAd!.show();
//       _interstitialAd = null;
//     }
//   }

//   static void createRewardedAd() {
//     RewardedAd.load(
//       adUnitId: _getRewardedAdUnitId(),
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (RewardedAd ad) {
//           _rewardedAd = ad;
//           _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
//             onAdShowedFullScreenContent: (RewardedAd ad) =>
//                 debugPrint('Rewarded Ad Showed'),
//             onAdDismissedFullScreenContent: (RewardedAd ad) {
//               ad.dispose();
//               createRewardedAd();
//             },
//             onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//               ad.dispose();
//               createRewardedAd();
//               debugPrint('Rewarded Ad Failed to Show: $error');
//             },
//           );
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           debugPrint('Rewarded Ad Failed to Load: $error');
//         },
//       ),
//     );
//   }

//   static void showRewardedAd({
//     Function(AdWithoutView, RewardItem)? onUserEarnedReward,
//   }) {
//     if (_rewardedAd != null) {
//       _rewardedAd!.show(
//         onUserEarnedReward:
//             onUserEarnedReward ??
//             (AdWithoutView ad, RewardItem reward) {
//               debugPrint('User earned reward: ${reward.amount} ${reward.type}');
//             },
//       );
//       _rewardedAd = null;
//     }
//   }

//   static void loadAppOpenAd() {
//     AppOpenAd.load(
//       adUnitId: _getAppOpenAdUnitId(),
//       request: const AdRequest(),
//       adLoadCallback: AppOpenAdLoadCallback(
//         onAdLoaded: (AppOpenAd ad) {
//           _appOpenAd = ad;
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           debugPrint('App Open Ad Failed to Load: $error');
//         },
//       ),
//     );
//   }

//   static void showAppOpenAdIfAvailable() {
//     if (_appOpenAd != null && !_isShowingAd) {
//       _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
//         onAdShowedFullScreenContent: (AppOpenAd ad) {
//           _isShowingAd = true;
//           debugPrint('App Open Ad Showed');
//         },
//         onAdDismissedFullScreenContent: (AppOpenAd ad) {
//           _isShowingAd = false;
//           ad.dispose();
//           _appOpenAd = null;
//           loadAppOpenAd();
//         },
//         onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
//           _isShowingAd = false;
//           ad.dispose();
//           _appOpenAd = null;
//           debugPrint('App Open Ad Failed to Show: $error');
//           loadAppOpenAd();
//         },
//       );
//       _appOpenAd!.show();
//     } else {
//       debugPrint('App Open Ad not ready');
//       loadAppOpenAd();
//     }
//   }

//   static void disposeAds() {
//     _bannerAd?.dispose();
//     _interstitialAd?.dispose();
//     _rewardedAd?.dispose();
//     _appOpenAd?.dispose();
//   }
// }
