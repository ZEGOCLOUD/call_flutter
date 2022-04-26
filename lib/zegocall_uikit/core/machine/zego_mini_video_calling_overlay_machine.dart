// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import '../../../logger.dart';

enum MiniVideoCallingOverlayState {
  kIdle,
  kWaiting,
  kWithVideo,
  kBothWithoutVideo,
}

typedef MiniVideoCallingOverlayMachineStateChanged = void Function(
    MiniVideoCallingOverlayState);

class ZegoMiniVideoCallingOverlayMachine {
  final machine = sm.Machine<MiniVideoCallingOverlayState>();
  MiniVideoCallingOverlayMachineStateChanged? onStateChanged;

  late sm.State<MiniVideoCallingOverlayState> stateIdle;
  late sm.State<MiniVideoCallingOverlayState> stateWithVideo;

  void init() {
    machine.onAfterTransition.listen((event) {
      logInfo('mini video, from ${event.source} to ${event.target}');

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    // Config state
    stateIdle = machine.newState(MiniVideoCallingOverlayState.kIdle);
    stateWithVideo =
        machine.newState(MiniVideoCallingOverlayState.kWithVideo);
  }

  MiniVideoCallingOverlayState getPageState() {
    return machine.current?.identifier ?? MiniVideoCallingOverlayState.kIdle;
  }
}
