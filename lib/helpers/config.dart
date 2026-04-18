import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class Config {
  static final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  /// ================= DEFAULT VALUES =================
  static const Map<String, dynamic> _defaultValues = {
    // Interstitial
    "interstitial_ad": "ca-app-pub-9021132987511379/4541538592",
    "interstitial_start_ad": "ca-app-pub-9021132987511379/4597378913",
    "interstitial_get_start_ad": "ca-app-pub-9021132987511379/1466318110",
    "interstitial_select": "ca-app-pub-9021132987511379/2176197301",

    // Native
    "native_ad": "ca-app-pub-9021132987511379/6447182056",
    "native_language_ad": "ca-app-pub-9021132987511379/5800314793",
    "native_info_ad": "ca-app-pub-9021132987511379/9068908715",
    "native_page_1": "ca-app-pub-9021132987511379/5441222145",
    "native_page_2": "ca-app-pub-9021132987511379/3848938873",
    "native_page_3": "ca-app-pub-9021132987511379/1501977139",
    "native_select": "ca-app-pub-9021132987511379/7592742761",

    // Reward
    "rewarded_ad": "ca-app-pub-9021132987511379/8718122177",

    // Banner
    "banner_ad": "ca-app-pub-9021132987511379/3855142880",
    "banner_home_ad": "ca-app-pub-9021132987511379/1228979541",

    // Flags
    "show_ads": true,
    "show_ads_iOS": false,
    "show_ads_before": true,
    "checkYouTube": true,

    // 🔥 IMPORTANT: JSON phải là String
    "keys": '{"list":[]}',
    "youtube": '{"list":[]}',
  };

  /// ================= INIT =================
  static Future<void> initConfig() async {
    await _config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 30),
      ),
    );

    // ✅ set full default (KHÔNG bị crash nữa)
    await _config.setDefaults(_defaultValues);

    // fetch từ server
    await _config.fetchAndActivate();

    // auto update realtime
    _config.onConfigUpdated.listen((event) async {
      await _config.activate();
    });
  }

  /// ================= JSON KEYS =================
  static List<String> get listKeysRemotes {
    try {
      final jsonString = _config.getString('keys');
      if (jsonString.isEmpty) return [];

      final data = jsonDecode(jsonString);
      return List<String>.from(data['list'] ?? []);
    } catch (e) {
      return [];
    }
  }

  static List<String> get listKeysYoutube {
    try {
      final jsonString = _config.getString('youtube');
      if (jsonString.isEmpty) return [];

      final data = jsonDecode(jsonString);
      return List<String>.from(data['list'] ?? []);
    } catch (e) {
      return [];
    }
  }

  /// ================= BOOL =================
  static bool get showAds =>
      _config.getBool("show_ads");

  static bool get showAdsIOS =>
      _config.getBool("show_ads_iOS");

  static bool get showAdsBefore =>
      _config.getBool("show_ads_before");

  static bool get checkYouTube =>
      _config.getBool("checkYouTube");
  /// ================= NATIVE =================
  static String get nativeAd =>
      _config.getString("native_ad");

  static String get nativeLanguageAd =>
      _config.getString("native_language_ad");

  static String get nativeInfoAd =>
      _config.getString("native_info_ad");

  static String get nativePage1Ad =>
      _config.getString("native_page_1");

  static String get nativePage2Ad =>
      _config.getString("native_page_2");

  static String get nativePage3Ad =>
      _config.getString("native_page_3");

  static String get nativeSelectAd =>
      _config.getString("native_select");

  /// ================= INTERSTITIAL =================
  static String get interstitialAd =>
      _config.getString("interstitial_ad");

  static String get interstitialStartAd =>
      _config.getString("interstitial_start_ad");

  static String get interstitialGetStartAd =>
      _config.getString("interstitial_get_start_ad");

  static String get interstitialSelectAd =>
      _config.getString("interstitial_select");

  /// ================= REWARDED =================
  static String get rewardedAd =>
      _config.getString("rewarded_ad");

  /// ================= BANNER =================
  static String get bannerAd =>
      _config.getString("banner_ad");

  static String get bannerHomeAd =>
      _config.getString("banner_home_ad");

  /// ================= HELPERS =================
  static bool get hideAds => !showAdsIOS;
  static bool get hideAdsBefore => !showAdsBefore;
}