// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import 'mini_video_calling_overlay_machine.dart';
import 'mini_voice_calling_overlay_machine.dart';

enum MiniOverlayPageState {
  kIdle,
  kBeInvite,
  kVoiceCalling,
  kVideoCalling,
}

typedef MiniOverlayMachineStateChanged = void Function(MiniOverlayPageState);

class MiniOverlayMachine {
  final machine = sm.Machine<MiniOverlayPageState>();
  MiniOverlayMachineStateChanged? onStateChanged;

  late sm.State<MiniOverlayPageState> stateIdle;
  late sm.State<MiniOverlayPageState> stateVoiceCalling;
  late sm.State<MiniOverlayPageState> stateVideoCalling;
  late sm.State<MiniOverlayPageState> stateBeInvite;

  late MiniVoiceCallingOverlayMachine voiceCallingOverlayMachine;
  late MiniVideoCallingOverlayMachine videoCallingOverlayMachine;

  void init() {
    machine.onAfterTransition.listen((event) {
      log('[state machine] mini overlay, from ${event.source} to ${event.target}');

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    stateIdle = machine.newState(MiniOverlayPageState.kIdle); //  default state;
    stateVoiceCalling = machine.newState(MiniOverlayPageState.kVoiceCalling);
    stateVideoCalling = machine.newState(MiniOverlayPageState.kVideoCalling);
    stateBeInvite = machine.newState(MiniOverlayPageState.kBeInvite);

    initVoiceCallingOverlayMachine();
    initVideoCallingOverlayMachine();
  }

  void initVoiceCallingOverlayMachine() {
    voiceCallingOverlayMachine = MiniVoiceCallingOverlayMachine();
    voiceCallingOverlayMachine.init();

    voiceCallingOverlayMachine.stateIdle.onEntry(() {
      stateIdle.enter();
    });
  }

  void initVideoCallingOverlayMachine() {
    videoCallingOverlayMachine = MiniVideoCallingOverlayMachine();
    videoCallingOverlayMachine.init();

    videoCallingOverlayMachine.stateIdle.onEntry(() {
      stateIdle.enter();
    });
    videoCallingOverlayMachine.stateBothWithoutVideo.onEntry(() {
      stateVoiceCalling.enter();
    });
  }
}
