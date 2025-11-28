import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  // Toggle this to use test ads during development
  static const bool _forceTestAds = true;

  // Your real Ad Unit IDs
  static const String _realBannerAndroid =
      'ca-app-pub-4314688595118324/6648060596';
  static const String _realInterstitialAndroid =
      'ca-app-pub-4314688595118324/7515130143';

  // Google's official test Ad Unit IDs
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';

  static String get bannerAdUnitId {
    if (_forceTestAds || kDebugMode) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    if (Platform.isAndroid) {
      return _realBannerAndroid;
    } else if (Platform.isIOS) {
      return _realBannerAndroid; // Add your iOS banner ID when ready
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (_forceTestAds || kDebugMode) {
      return Platform.isAndroid
          ? _testInterstitialAndroid
          : _testInterstitialIOS;
    }
    if (Platform.isAndroid) {
      return _realInterstitialAndroid;
    } else if (Platform.isIOS) {
      return ''; // Add your iOS interstitial ID when ready
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();

    // Register your test device
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['C71FBE177D8E33F1528BF0D74358F703']),
    );

    debugPrint('AdMob initialized. Force test ads: $_forceTestAds');
  }

  // Create a Banner Ad Widget
  BannerAd createBannerAd({
    Function(Ad)? onLoaded,
    Function(Ad, LoadAdError)? onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded.');
          onLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          onFailed?.call(ad, error);
        },
        onAdOpened: (ad) => debugPrint('Banner ad opened.'),
        onAdClosed: (ad) => debugPrint('Banner ad closed.'),
      ),
    );
  }

  // Create a large Banner Ad Widget
  BannerAd createLargeBannerAd({
    Function(Ad)? onLoaded,
    Function(Ad, LoadAdError)? onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Large banner ad loaded.');
          onLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Large banner ad failed to load: $error');
          ad.dispose();
          onFailed?.call(ad, error);
        },
        onAdOpened: (ad) => debugPrint('Large banner ad opened.'),
        onAdClosed: (ad) => debugPrint('Large banner ad closed.'),
      ),
    );
  }

  // Load Interstitial Ad
  void loadInterstitialAd({VoidCallback? onAdLoaded}) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded.');
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _isInterstitialAdReady = true;

          _interstitialAd!.setImmersiveMode(true);

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  debugPrint('Interstitial ad showed fullscreen content.');
                },
                onAdDismissedFullScreenContent: (ad) {
                  debugPrint('Interstitial ad dismissed.');
                  ad.dispose();
                  _isInterstitialAdReady = false;
                  loadInterstitialAd();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  debugPrint('Interstitial ad failed to show: $error');
                  ad.dispose();
                  _isInterstitialAdReady = false;
                  loadInterstitialAd();
                },
              );

          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          _isInterstitialAdReady = false;

          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(
              Duration(seconds: _numInterstitialLoadAttempts * 2),
              () => loadInterstitialAd(onAdLoaded: onAdLoaded),
            );
          }
        },
      ),
    );
  }

  // Show Interstitial Ad with optional callback
  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial ad dismissed.');
          ad.dispose();
          _isInterstitialAdReady = false;
          onAdDismissed?.call();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Interstitial ad failed to show: $error');
          ad.dispose();
          _isInterstitialAdReady = false;
          onAdDismissed?.call();
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad is not ready yet.');
      onAdDismissed?.call();
      loadInterstitialAd();
    }
  }

  bool get isInterstitialAdReady => _isInterstitialAdReady;

  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }

  void dispose() {
    disposeInterstitialAd();
  }
}
