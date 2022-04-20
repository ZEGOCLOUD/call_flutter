// Dart imports:
import 'dart:async';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

// Project imports:
import '../../logger.dart';

const String callRingName = 'CallRing.wav';

class ZegoNotificationRing {
  static var shared = ZegoNotificationRing();

  bool isRingTimerRunning = false;
  AudioPlayer? audioPlayer;
  late AudioCache audioCache;

  void init() {
    audioCache = AudioCache(
      prefix: 'assets/audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
  }

  void uninit() async {
    stopRing();

    await audioCache.clearAll();
  }

  void startRing() async {
    if (isRingTimerRunning) {
      logInfo('ring is running');
      return;
    }

    logInfo('start ring');

    isRingTimerRunning = true;

    await audioCache.loop(callRingName).then((player) => audioPlayer = player);
    Vibrate.vibrate();

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      logInfo('ring timer periodic');
      if (!isRingTimerRunning) {
        logInfo('ring timer ended');

        audioPlayer?.stop();

        timer.cancel();
      } else {
        Vibrate.vibrate();
      }
    });
  }

  void stopRing() async {
    logInfo('stop ring');

    isRingTimerRunning = false;

    audioPlayer?.stop();
  }
}
