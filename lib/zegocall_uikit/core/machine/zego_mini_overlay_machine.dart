// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import 'package:zego_call_flutter/zegocall_uikit/core/page/zego_page_route.dart';
import '../../../logger.dart';
import 'zego_mini_video_calling_overlay_machine.dart';
import 'zego_mini_voice_calling_overlay_machine.dart';

enum MiniOverlayPageState {
  kIdle,
  kBeInvite,
  kVoiceCalling,
  kVideoCalling,
}

typedef MiniOverlayMachineStateChanged = void Function(MiniOverlayPageState);

class ZegoMiniOverlayMachine {
  final machine = sm.Machine<MiniOverlayPageState>();
  MiniOverlayMachineStateChanged? onStateChanged;

  late sm.State<MiniOverlayPageState> stateIdle;
  late sm.State<MiniOverlayPageState> stateVoiceCalling;
  late sm.State<MiniOverlayPageState> stateVideoCalling;
  late sm.State<MiniOverlayPageState> stateBeInvite;

  late ZegoMiniVoiceCallingOverlayMachine voiceCallingOverlayMachine;
  late ZegoMiniVideoCallingOverlayMachine videoCallingOverlayMachine;

  void init() {
    machine.onAfterTransition.listen((event) {
      logInfo(
          '[state machine] mini overlay, from ${event.source} to ${event.target}');

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    stateIdle = machine.newState(MiniOverlayPageState.kIdle)
      ..onEntry(() {
        MiniVoiceCallingOverlayState voiceState =
            voiceCallingOverlayMachine.machine.current?.identifier ??
                MiniVoiceCallingOverlayState.kIdle;
        if (voiceState != MiniVoiceCallingOverlayState.kIdle) {
          voiceCallingOverlayMachine.stateIdle.enter();
        }

        MiniVideoCallingOverlayState videoState =
            videoCallingOverlayMachine.machine.current?.identifier ??
                MiniVideoCallingOverlayState.kIdle;
        if (videoState != MiniVideoCallingOverlayState.kIdle) {
          videoCallingOverlayMachine.stateIdle.enter();
        }
      }); //  default state;
    stateVoiceCalling = machine.newState(MiniOverlayPageState.kVoiceCalling)
      ..onEntry(() {
        ZegoPageRoute.shared.navigatePopCalling();

        // sync current voice state
      });
    stateVideoCalling = machine.newState(MiniOverlayPageState.kVideoCalling)
      ..onEntry(() {
        ZegoPageRoute.shared.navigatePopCalling();

        // sync current video state
      });
    stateBeInvite = machine.newState(MiniOverlayPageState.kBeInvite);

    initVoiceCallingOverlayMachine();
    initVideoCallingOverlayMachine();
  }

  void initVoiceCallingOverlayMachine() {
    voiceCallingOverlayMachine = ZegoMiniVoiceCallingOverlayMachine();
    voiceCallingOverlayMachine.init();

    voiceCallingOverlayMachine.stateIdle.onEntry(() {
      stateIdle.enter();
    });
  }

  void initVideoCallingOverlayMachine() {
    videoCallingOverlayMachine = ZegoMiniVideoCallingOverlayMachine();
    videoCallingOverlayMachine.init();

    videoCallingOverlayMachine.stateIdle.onEntry(() {
      stateIdle.enter();
    });
  }

  void checkEnterVoiceState() {
    if (MiniOverlayPageState.kVoiceCalling != getPageState()) {
      stateVoiceCalling.enter();
    }
  }

  void checkEnterVideoState() {
    if (MiniOverlayPageState.kVideoCalling != getPageState()) {
      stateVideoCalling.enter();
    }
  }

  MiniOverlayPageState getPageState() {
    return machine.current?.identifier ?? MiniOverlayPageState.kIdle;
  }
}
