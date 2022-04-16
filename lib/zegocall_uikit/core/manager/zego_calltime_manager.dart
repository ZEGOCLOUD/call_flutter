import 'dart:async';

import 'dart:developer';

import 'package:flutter/cupertino.dart';

class ZegoCallingTimer {
  bool isCalling = false;

  int startTime = 0;
  int callDuration = 0;
  ValueNotifier<String> formatCallTimeNotifier = ValueNotifier<String>("");

  void startTimer() {
    log('[calling timer] start timer, isCalling:$isCalling');

    isCalling = true;
    startTime = DateTime.now().millisecondsSinceEpoch;

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      log('[calling timer] calling timer periodic');
      if (!isCalling) {
        log('[calling timer] calling timer ended');

        timer.cancel();
      } else {
        callDuration = DateTime.now().millisecondsSinceEpoch - startTime;

        var duration = Duration(seconds: callDuration ~/ 1000);
        var minutes =
            duration.inMinutes.remainder(60).toString().padLeft(2, '0');
        var seconds =
            duration.inSeconds.remainder(60).toString().padLeft(2, '0');
        formatCallTimeNotifier.value = minutes + ":" + seconds;
      }
    });
  }

  void stopTimer() {
    log('[calling timer] stop timer');

    isCalling = false;

    startTime = 0;
    callDuration = 0;
    formatCallTimeNotifier = ValueNotifier<String>("");
  }
}

class ZegoCallingTimeManager {
  ZegoCallingTimeManager.empty();

  Map<String, ZegoCallingTimer> timers = {};

  ZegoCallingTimer startTimer(String key) {
    if (timers.containsKey(key)) {
      log('[calling timer manager] start timer, existed, return $key');
      return timers[key]!;
    }

    log('[calling timer manager] start timer, create and start $key');
    var timer = ZegoCallingTimer();
    timer.startTimer();
    timers[key] = timer;

    return timer;
  }

  ZegoCallingTimer getTimer(String key) {
    if (timers.containsKey(key)) {
      return timers[key]!;
    }

    log('[calling timer manager] get timer, has not $key, return empty timer');
    return ZegoCallingTimer();
  }

  void stopTimer(String key) {
    if (!timers.containsKey(key)) {
      log('[calling timer manager] stop timer, has not $key');
      return;
    }

    log('[calling timer manager] stop timer, stop and remove $key');
    timers[key]!.stopTimer();
    timers.remove(key);
  }
}
