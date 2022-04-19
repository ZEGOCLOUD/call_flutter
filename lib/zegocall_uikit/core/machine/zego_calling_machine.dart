// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import '../../../logger.dart';
import '../page/zego_page_route.dart';

enum CallingState {
  kIdle,
  kCallingWithVoice,
  kCallingWithVideo,
  kOnlineVoice,
  kOnlineVideo,
}

typedef CallingMachineStateChanged = void Function(CallingState);

class ZegoCallingMachine {
  final machine = sm.Machine<CallingState>();
  CallingMachineStateChanged? onStateChanged;

  late sm.State<CallingState> stateIdle;
  late sm.State<CallingState> stateCallingWithVoice;
  late sm.State<CallingState> stateCallingWithVideo;
  late sm.State<CallingState> stateOnlineVoice;
  late sm.State<CallingState> stateOnlineVideo;

  void init() {
    machine.onAfterTransition.listen((event) {
      logInfo('calling, from ${event.source} to ${event.target}');

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    stateIdle = machine.newState(CallingState.kIdle)
      ..onEntry(() {
        ZegoPageRoute.shared.navigatePopCalling();
      }); // default state

    stateCallingWithVoice = machine.newState(CallingState.kCallingWithVoice)
      ..onEntry(() {
        ZegoPageRoute.shared.navigatePopCalling(isForce: true);
      });
    stateCallingWithVideo = machine.newState(CallingState.kCallingWithVideo)
      ..onEntry(() {
        ZegoPageRoute.shared.navigatePopCalling(isForce: true);
      });
    stateOnlineVoice = machine.newState(CallingState.kOnlineVoice)
      ..onEntry(() {
        ZegoPageRoute.shared.navigatePopCalling(isForce: true);
      });
    stateOnlineVideo = machine.newState(CallingState.kOnlineVideo)
      ..onEntry(() {
        ZegoPageRoute.shared.navigatePopCalling(isForce: true);
      });
  }

  CallingState getPageState() {
    return machine.current?.identifier ?? CallingState.kIdle;
  }
}
