// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../logger.dart';

class ZegoCallingTimer {
  bool isCalling = false;

  int startTime = 0;
  ValueNotifier<String> displayValueNotifier = ValueNotifier<String>("");

  void startTimer() {
    logInfo('isCalling:$isCalling');

    isCalling = true;
    startTime = DateTime.now().millisecondsSinceEpoch;

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      // logInfo('calling timer periodic');
      if (!isCalling) {
        logInfo('calling timer ended');

        timer.cancel();
      } else {
        var callSeconds =
            (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
        var minutes = callSeconds ~/ 60;
        var seconds = (callSeconds - 60 * minutes).toInt();
        var minutesString = minutes.toString().padLeft(2, '0');
        var secondsString = seconds.toString().padLeft(2, '0');
        displayValueNotifier.value = minutesString + ":" + secondsString;
      }
    });
  }

  void stopTimer() {
    logInfo('stop');

    isCalling = false;

    startTime = 0;
    displayValueNotifier = ValueNotifier<String>("");
  }
}

class ZegoCallingTimeManager {
  ZegoCallingTimeManager.empty();

  Map<String, ZegoCallingTimer> timers = {};

  ZegoCallingTimer startTimer(String key) {
    if (timers.containsKey(key)) {
      logInfo('existed, return $key');
      return timers[key]!;
    }

    logInfo('create and start $key');
    var timer = ZegoCallingTimer();
    timer.startTimer();
    timers[key] = timer;

    return timer;
  }

  ZegoCallingTimer getTimer(String key) {
    if (timers.containsKey(key)) {
      return timers[key]!;
    }

    logInfo('has not $key, return empty timer');
    return ZegoCallingTimer();
  }

  void stopTimer(String key) {
    if (!timers.containsKey(key)) {
      logInfo('has not $key');
      return;
    }

    logInfo('stop and remove $key');
    timers[key]!.stopTimer();
    timers.remove(key);
  }
}
