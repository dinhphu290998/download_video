import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'config.dart';
import 'my_dialogs.dart';

class AdHelper {
  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }

  // ================= INTERSTITIAL =================

  static InterstitialAd? _interstitialAd;

  static void loadInterstitial() {
    if (Config.hideAds) return;

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          log('Interstitial failed: ${err.message}');
        },
      ),
    );
  }

  static void showInterstitial(VoidCallback onComplete) {
    if (Config.hideAds) return onComplete();

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial();
              onComplete();
            },
          );

      _interstitialAd!.show();
      return;
    }

    onComplete();
    loadInterstitial();
  }

  // ================= REWARDED =================

  static void showRewarded(VoidCallback onReward) {
    if (Config.hideAds) return onReward();

    // Show progress dialog (chỉ nếu Get có context)
    if (Get.isRegistered<GetxController>() || Get.isSnackbarOpen || Get.isDialogOpen == false) {
      MyDialogs.showProgress();
    }

    RewardedAd.load(
      adUnitId: Config.rewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          // Chỉ pop dialog nếu nó đang mở
          if (Get.isDialogOpen ?? false) Get.back();
          ad.show(onUserEarnedReward: (_, __) => onReward());
        },
        onAdFailedToLoad: (err) {
          onReward();
          if (Get.isDialogOpen ?? false) Get.back();
          log('Rewarded failed: ${err.message}');
        },
      ),
    );
  }

  // ================= BANNER =================

  static BannerAd? loadBanner({
    required BannerAdController controller,
  }) {
    if (Config.hideAds) return null;

    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: Config.bannerAd,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          controller.adLoaded.value = true;
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          log('Banner failed: ${err.message}');
        },
      ),
    );

    ad.load();
    return ad;
  }

  // ================= NATIVE (CORE) =================

  static NativeAd _createNative({
    required String adUnitId,
    required NativeAdController controller,
  }) {
    final ad = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          controller.adLoaded.value = true;
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          log('Native failed: ${err.message}');
        },
      ),
      nativeTemplateStyle:
      NativeTemplateStyle(templateType: TemplateType.medium),
    );

    ad.load();
    return ad;
  }

  // ================= LANGUAGE ADS =================

  static NativeAd loadNativeLanguage(ValueNotifier<bool> adLoadedNotifier) {
    final controller = NativeAdController();
    controller.adLoaded = adLoadedNotifier;
    return _createNative(
      adUnitId: Config.nativeLanguageAd,
      controller: controller,
    );
  }

  // ================= HISTORY ADS =================

  static NativeAd loadNativeHistory(ValueNotifier<bool> adLoadedNotifier) {
    final controller = NativeAdController();
    controller.adLoaded = adLoadedNotifier;
    return _createNative(
      adUnitId: Config.nativeSelectAd,
      controller: controller,
    );
  }

  // ================= HOME ADS =================

  static NativeAd loadNativeHome(ValueNotifier<bool> adLoadedNotifier) {
    final controller = NativeAdController();
    controller.adLoaded = adLoadedNotifier;
    return _createNative(
      adUnitId: Config.nativeAd,
      controller: controller,
    );
  }

  // ================= ONBOARDING ADS =================

  static NativeAd? loadNativePage1Ad({
    required NativeAdController adController,
  }) {
    if (Config.hideAds) return null;

    return _createNative(
      adUnitId: Config.nativePage1Ad,
      controller: adController,
    );
  }

  static NativeAd? loadNativePage2Ad({
    required NativeAdController adController,
  }) {
    if (Config.hideAds) return null;

    return _createNative(
      adUnitId: Config.nativePage2Ad,
      controller: adController,
    );
  }

  static NativeAd? loadNativePage3Ad({
    required NativeAdController adController,
  }) {
    if (Config.hideAds) return null;

    return _createNative(
      adUnitId: Config.nativePage3Ad,
      controller: adController,
    );
  }
}

// ================= CONTROLLERS =================

class BannerAdController {
  ValueNotifier<bool> adLoaded = ValueNotifier(false);
  BannerAd? bannerAd;

  void dispose() {
    adLoaded.dispose();
    bannerAd?.dispose();
  }
}

class NativeAdController {
  ValueNotifier<bool> adLoaded = ValueNotifier(false);
  NativeAd? ad;

  void dispose() {
    adLoaded.dispose();
    ad?.dispose();
  }
}