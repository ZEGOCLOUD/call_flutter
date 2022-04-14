// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import '../../../zegocall_demo/constants/zego_page_constant.dart';
import '../page/zego_page_route.dart';

enum CallingState {
  kIdle,
  kCallingWithVoice,
  kCallingWithVideo,
  kOnlineVoice,
  kOnlineVideo,
}

typedef CallingMachineStateChanged = void Function(CallingState);

class CallingMachine {
  final machine = sm.Machine<CallingState>();
  CallingMachineStateChanged? onStateChanged;

  late sm.State<CallingState> stateIdle;
  late sm.State<CallingState> stateCallingWithVoice;
  late sm.State<CallingState> stateCallingWithVideo;
  late sm.State<CallingState> stateOnlineVoice;
  late sm.State<CallingState> stateOnlineVideo;

  void init() {
    machine.onAfterTransition.listen((event) {
      log('[state machine] calling, from ${event.source} to ${event.target}');

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
        ZegoPageRoute.shared.navigatorPush(PageRouteNames.calling);
      });
    stateCallingWithVideo = machine.newState(CallingState.kCallingWithVideo)
      ..onEntry(() {
        ZegoPageRoute.shared.navigatorPush(PageRouteNames.calling);
      });
    stateOnlineVoice = machine.newState(CallingState.kOnlineVoice)
      ..onEntry(() {
        ZegoPageRoute.shared
            .navigatorPush(PageRouteNames.calling, isForce: true);
      });
    stateOnlineVideo = machine.newState(CallingState.kOnlineVideo)
      ..onEntry(() {
        ZegoPageRoute.shared
            .navigatorPush(PageRouteNames.calling, isForce: true);
      });
  }

  CallingState getPageState() {
    return machine.current?.identifier ?? CallingState.kIdle;
  }
}
