// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

enum MiniVideoCallingOverlayState {
  kIdle,
  kWaiting,
  kCalleeWithVideo,
  kOnlyCallerWithVideo,
  kBothWithoutVideo,
}

typedef MiniVideoCallingOverlayMachineStateChanged = void Function(
    MiniVideoCallingOverlayState);

class MiniVideoCallingOverlayMachine {
  final machine = sm.Machine<MiniVideoCallingOverlayState>();
  MiniVideoCallingOverlayMachineStateChanged? onStateChanged;

  late sm.State<MiniVideoCallingOverlayState> stateIdle;
  late sm.State<MiniVideoCallingOverlayState> stateWaiting;
  late sm.State<MiniVideoCallingOverlayState> stateCalleeWithVideo;
  late sm.State<MiniVideoCallingOverlayState> stateOnlyCallerWithVideo;
  late sm.State<MiniVideoCallingOverlayState> stateBothWithoutVideo;

  // The duration may change on full screen calling page
  final int waitingDuration = 60;

  void init() {
    machine.onAfterTransition.listen((event) {
      log('[state machine] mini video, from ${event.source} to ${event.target}');

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    // Config state
    stateIdle = machine.newState(MiniVideoCallingOverlayState.kIdle);
    stateWaiting = machine.newState(MiniVideoCallingOverlayState.kWaiting)
      ..onTimeout(Duration(seconds: waitingDuration), () => stateIdle.enter());
    stateCalleeWithVideo =
        machine.newState(MiniVideoCallingOverlayState.kCalleeWithVideo);
    stateOnlyCallerWithVideo =
        machine.newState(MiniVideoCallingOverlayState.kOnlyCallerWithVideo);
    stateBothWithoutVideo = machine.newState(MiniVideoCallingOverlayState
        .kBothWithoutVideo); //  todo page handle 监听处理
  }
}
