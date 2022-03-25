import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statemachine/statemachine.dart' as sm;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/page/calling/calling_state.dart';
import 'package:zego_call_flutter/page/calling/calling_caller_view.dart';
import 'package:zego_call_flutter/page/calling/online_video_view.dart';
import 'package:zego_call_flutter/page/calling/online_voice_view.dart';

import '../../model/zego_user_info.dart';
import '../../service/zego_call_service.dart';
import '../../service/zego_user_service.dart';
import 'calling_callee_view.dart';

class CallingPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CallingPage({Key? key}) : super(key: key);

  @override
  _CallingPageState createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  CallingState currentState = CallingState.kIdle;

  final machine = sm.Machine<CallingState>();
  late sm.State<CallingState> stateIdle;
  late sm.State<CallingState> stateCallingWithVoice;
  late sm.State<CallingState> stateCallingWithVideo;
  late sm.State<CallingState> stateOnlineVoice;
  late sm.State<CallingState> stateOnlineVideo;

  void updatePageCurrentState() {
    setState(() => currentState = machine.current!.identifier);
  }

  @override
  void initState() {
    initStateMachine();
    registerCallService();

    super.initState();
  }

  void initStateMachine() {
    machine.onAfterTransition.listen((event) {
      updatePageCurrentState();
    });

    stateIdle = machine.newState(CallingState.kIdle) // default state
      ..onTimeout(
          const Duration(seconds: 3), () => stateCallingWithVideo.enter())
      ..onEntry(() {
        print("Calling page entry idle state...");
      });
    stateCallingWithVoice = machine.newState(CallingState.kCallingWithVoice);
    stateCallingWithVideo = machine.newState(CallingState.kCallingWithVideo);
    stateOnlineVoice = machine.newState(CallingState.kOnlineVoice);
    stateOnlineVideo = machine.newState(CallingState.kOnlineVideo);

    machine.start();
  }

  void registerCallService() {
    // Listen on CallService event
    final callService = context.read<ZegoCallService>();
    callService.onReceiveCallEnded = () => stateIdle.enter();
    callService.onReceiveCallCancel = (ZegoUserInfo info) => stateIdle.enter();
    callService.onReceiveCallResponse =
        (ZegoUserInfo calleeInfo, ZegoCallType type) {
      // TODO update UI info
      if (type == ZegoCallType.kZegoCallTypeVideo) {
        stateOnlineVideo.enter();
      } else {
        stateOnlineVoice.enter();
      }
    };
    callService.onReceiveCallTimeout =
        (ZegoCallTimeoutType type) => stateIdle.enter();
  }

  @override
  Widget build(BuildContext context) {
    final pageParams =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    //  test
    print(pageParams);

    ZegoUserInfo caller = ZegoUserInfo('001', 'name 1', 0);
    ZegoUserInfo callee = ZegoUserInfo('002', 'name 2', 0);

    final localUserID = context.read<ZegoUserService>().localUserInfo.userID;
    var localUserIsCaller = localUserID == caller.userID;
    var callType = currentState == CallingState.kCallingWithVideo
        ? ZegoCallType.kZegoCallTypeVideo
        : ZegoCallType.kZegoCallTypeVoice;

    switch (currentState) {
      case CallingState.kIdle:
        return const SizedBox();
      case CallingState.kCallingWithVoice:
      case CallingState.kCallingWithVideo:
        return localUserIsCaller
            ? CallingCallerView(
                caller: caller,
                callee: callee,
                callType: callType,
              )
            : CallingCalleeView(
                caller: caller,
                callee: callee,
                callType: callType,
              );
      case CallingState.kOnlineVoice:
        return OnlineVoiceView(
          caller: caller,
          callee: callee,
        );
      case CallingState.kOnlineVideo:
        return OnlineVideoView(
          caller: caller,
          callee: callee,
        );
    }
  }
}
