// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_call_flutter/zegocall_uikit/core/page/zego_page_route.dart';

import '../../../zegocall_demo/constants/zego_page_constant.dart';

enum MiniVoiceCallingOverlayState {
  kIdle,
  kWaiting,
  kOnline,
  kDeclined,
  kMissed,
  kEnded,
}

typedef MiniVoiceCallingOverlayMachineStateChanged = void Function(
    MiniVoiceCallingOverlayState);

class MiniVoiceCallingOverlayMachine {
  final machine = sm.Machine<MiniVoiceCallingOverlayState>();
  MiniVoiceCallingOverlayMachineStateChanged? onStateChanged;

  late sm.State<MiniVoiceCallingOverlayState> stateIdle;
  late sm.State<MiniVoiceCallingOverlayState> stateWaiting;
  late sm.State<MiniVoiceCallingOverlayState> stateOnline;
  late sm.State<MiniVoiceCallingOverlayState> stateDeclined;
  late sm.State<MiniVoiceCallingOverlayState> stateMissed;
  late sm.State<MiniVoiceCallingOverlayState> stateEnded;
  int waitingDuration = 60;

  void init() {
    // Update current for drive UI rebuild
    machine.onAfterTransition.listen((event) {
      log('[state machine] mini voice, from ${event.source} to ${event.target}');

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    // Config state
    stateIdle = machine.newState(MiniVoiceCallingOverlayState.kIdle);
    stateWaiting = machine.newState(MiniVoiceCallingOverlayState.kWaiting);
    stateOnline = machine.newState(MiniVoiceCallingOverlayState.kOnline);

    var toIdleDuration = const Duration(seconds: 2);
    stateDeclined = machine.newState(MiniVoiceCallingOverlayState.kDeclined)
      ..onTimeout(toIdleDuration, () => stateIdle.enter());
    stateMissed = machine.newState(MiniVoiceCallingOverlayState.kMissed)
      ..onTimeout(toIdleDuration, () => stateIdle.enter());
    stateEnded = machine.newState(MiniVoiceCallingOverlayState.kEnded)
      ..onTimeout(toIdleDuration, () => stateIdle.enter());

    // machine.current = widget.defaultState;
  }
}
