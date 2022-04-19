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
        ZegoPageRoute.shared.popToCallingParentPage();
      }); // default state

    stateCallingWithVoice = machine.newState(CallingState.kCallingWithVoice)
      ..onEntry(() {
        assert(ZegoPageRoute.shared.callingPageRouteName.isNotEmpty,
            "calling page rout name is empty");
        ZegoPageRoute.shared.push(ZegoPageRoute.shared.callingPageRouteName);
      });
    stateCallingWithVideo = machine.newState(CallingState.kCallingWithVideo)
      ..onEntry(() {
        assert(ZegoPageRoute.shared.callingPageRouteName.isNotEmpty,
            "calling page rout name is empty");
        ZegoPageRoute.shared.push(ZegoPageRoute.shared.callingPageRouteName);
      });
    stateOnlineVoice = machine.newState(CallingState.kOnlineVoice)
      ..onEntry(() {
        assert(ZegoPageRoute.shared.callingPageRouteName.isNotEmpty,
            "calling page rout name is empty");
        ZegoPageRoute.shared.push(ZegoPageRoute.shared.callingPageRouteName);
      });
    stateOnlineVideo = machine.newState(CallingState.kOnlineVideo)
      ..onEntry(() {
        assert(ZegoPageRoute.shared.callingPageRouteName.isNotEmpty,
            "calling page rout name is empty");
        ZegoPageRoute.shared.push(ZegoPageRoute.shared.callingPageRouteName);
      });
  }

  CallingState getPageState() {
    return machine.current?.identifier ?? CallingState.kIdle;
  }
}
