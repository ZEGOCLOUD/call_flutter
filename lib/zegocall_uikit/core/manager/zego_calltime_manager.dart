class ZegoCallTimeManager {
  ZegoCallTimeManager.empty();

  bool isCalling = false;

  Stream<String>? timerStream;

  Stream<String> startTimer() {
    timerStream = Stream.periodic(const Duration(seconds: 1), (int count) {
      var duration = Duration(seconds: count);
      var minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      var seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return minutes + ":" + seconds;
    });

    timerStream!.takeWhile((element) => isCalling);

    return timerStream!;
  }

  void stopTimer() {
    isCalling = false;

    timerStream = null;
  }
}
