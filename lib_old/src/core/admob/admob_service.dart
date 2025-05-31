import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:safer_vpn/src/core/admob/AdManager.dart';

class AdMobService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;
  static void initialize() {
    MobileAds.instance.initialize();
  }

  static void createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId, // Replace with your ad unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Banner Ad Loaded'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (kDebugMode) {
            print('Banner Ad Failed to Load: $error');
          }
        },
        onAdOpened: (Ad ad) => print('Banner Ad Opened'),
        onAdClosed: (Ad ad) => print('Banner Ad Closed'),
      ),
    )..load();
  }

  static Widget showBannerAd() {
    if (_bannerAd != null) {
      return Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          AdManager.interstitialConnectAdUnitId, // Replace with your ad unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                print('Interstitial Ad Showed'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              createInterstitialAd();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
              createInterstitialAd();
              if (kDebugMode) {
                print('Interstitial Ad Failed to Show: $error');
              }
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('Interstitial Ad Failed to Load: $error');
          }
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  static void createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdManager.rewardAdUnitId, // Replace with your ad unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('Rewarded Ad Failed to Load: $error');
          }
        },
      ),
    );
  }

  static void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        if (kDebugMode) {
          print('User earned reward: ${reward.amount} ${reward.type}');
        }
      });
      _rewardedAd = null;
    }
  }

  static void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdManager.appOpenAdUnitId, // Replace with your ad unit ID
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('App Open Ad Failed to Load: $error');
          }
        },
      ),
    );
  }

  static void showAppOpenAdIfAvailable() {
    if (_appOpenAd != null && !_isShowingAd) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (AppOpenAd ad) {
          _isShowingAd = true;
          if (kDebugMode) {
            print('App Open Ad Showed');
          }
        },
        onAdDismissedFullScreenContent: (AppOpenAd ad) {
          _isShowingAd = false;
          ad.dispose();
          _appOpenAd = null;
          loadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
          _isShowingAd = false;
          ad.dispose();
          _appOpenAd = null;
          if (kDebugMode) {
            print('App Open Ad Failed to Show: $error');
          }
          loadAppOpenAd();
        },
      );
      _appOpenAd!.show();
    } else {
      if (kDebugMode) {
        print('App Open Ad not ready');
      }
      loadAppOpenAd();
    }
  }
}
