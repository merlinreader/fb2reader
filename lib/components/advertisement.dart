/*
import 'package:flutter/material.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardButton extends StatefulWidget {
  final String adUnitId;

  const RewardButton({
    required this.adUnitId,
  });

  @override
  _RewardButtonState createState() => _RewardButtonState();
}

class _RewardButtonState extends State<RewardButton> {
  late RewardedAd _rewardedAd;
  int _countWords = 0;

  @override
  void initState() {
    super.initState();
    _initializeCountWords();
    _loadRewardedAd();
  }

  Future<void> _initializeCountWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _countWords = prefs.getInt('count_words') ?? 0;
    });
  }

  Future<void> _saveCountWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count_words', _countWords);
  }

  Future<void> _loadRewardedAd() async {
    try {
      await YandexAds.init();
      _rewardedAd = RewardedAd(
        adUnitId: widget.adUnitId,
        listener: (event, {dynamic? args}) {
          final eventString = eventToString(event);
          print('Rewarded Ad event: $eventString');
          if (event == RewardedAdEvent.loaded) {
            setState(() {
              _rewardedAd.show();
            });
          } else if (event == RewardedAdEvent.failedToLoad) {
            // Обработка ошибки при загрузке рекламы
          }
        },
      );
      await _rewardedAd.load();
    } catch (e) {
      print('Failed to load rewarded ad: $e');
    }
  }

  String eventToString(RewardedAdEvent event) {
    switch (event) {
      case RewardedAdEvent.loaded:
        return 'loaded';
      case RewardedAdEvent.failedToLoad:
        return 'failedToLoad';
      case RewardedAdEvent.showed:
        return 'showed';
      case RewardedAdEvent.dismissed:
        return 'dismissed';
      case RewardedAdEvent.rewarded:
        return 'rewarded';
      case RewardedAdEvent.leftApplication:
        return 'leftApplication';
      default:
        return 'unknown';
    }
  }

  void _onAdLoaded() {
    setState(() {
      _countWords += 1;
    });
    _saveCountWords();
    // Выполнение других действий после загрузки рекламы
  }

  @override
  void dispose() {
    _rewardedAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_rewardedAd.isLoaded()) {
          _rewardedAd.show();
        }
      },
      child: Text('Получить награду'),
    );
  }
}
*/