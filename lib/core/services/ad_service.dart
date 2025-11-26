import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  // Test Ad Unit IDs - Replace with your actual AdMob IDs in production
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Banner Ad
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test Banner Ad
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial Ad
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test Interstitial Ad
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Create a Banner Ad Widget
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('Banner ad opened.');
        },
        onAdClosed: (ad) {
          print('Banner ad closed.');
        },
      ),
    );
  }

  // Create a large Banner Ad Widget (for item view)
  BannerAd createLargeBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Large banner ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          print('Large banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('Large banner ad opened.');
        },
        onAdClosed: (ad) {
          print('Large banner ad closed.');
        },
      ),
    );
  }

  // Load Interstitial Ad
  void loadInterstitialAd({Function? onAdLoaded}) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Interstitial ad loaded.');
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _isInterstitialAdReady = true;

          _interstitialAd!.setImmersiveMode(true);

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('Interstitial ad showed fullscreen content.');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('Interstitial ad dismissed.');
              ad.dispose();
              _isInterstitialAdReady = false;
              // Preload next interstitial ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              // Preload next interstitial ad
              loadInterstitialAd();
            },
          );

          if (onAdLoaded != null) {
            onAdLoaded();
          }
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
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

  // Show Interstitial Ad
  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('Interstitial ad is not ready yet.');
      // Load the ad if it's not ready
      loadInterstitialAd();
    }
  }

  // Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // Dispose interstitial ad
  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }

  // Dispose all ads
  void dispose() {
    disposeInterstitialAd();
  }
}
