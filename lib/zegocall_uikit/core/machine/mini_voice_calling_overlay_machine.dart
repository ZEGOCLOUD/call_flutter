// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

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

    var displayDuration = const Duration(seconds: 2);
    stateDeclined = machine.newState(MiniVoiceCallingOverlayState.kDeclined)
      ..onTimeout(displayDuration, () => stateIdle.enter());
    stateMissed = machine.newState(MiniVoiceCallingOverlayState.kMissed)
      ..onTimeout(displayDuration, () => stateIdle.enter());
    stateEnded = machine.newState(MiniVoiceCallingOverlayState.kEnded)
      ..onTimeout(displayDuration, () => stateIdle.enter());

    // machine.current = widget.defaultState;
  }

  MiniVoiceCallingOverlayState getPageState() {
    return machine.current?.identifier ?? MiniVoiceCallingOverlayState.kIdle;
  }
}
