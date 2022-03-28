import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:statemachine/statemachine.dart' as sm;

import 'package:zego_call_flutter/model/zego_user_info.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';
import 'package:zego_call_flutter/service/zego_user_service.dart';
import 'calling_callee_view.dart';

import 'calling_state.dart';
import 'calling_caller_view.dart';
import 'online_video_view.dart';
import 'online_voice_view.dart';

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

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.start();

      machine.current = stateOnlineVideo; // call test
    });
  }

  void initStateMachine() {
    machine.onAfterTransition.listen((event) {
      print(
          '[state machine] calling page: from ${event.source} to ${event.target}');

      updatePageCurrentState();
    });

    stateIdle = machine.newState(CallingState.kIdle); // default state;
    stateCallingWithVoice = machine.newState(CallingState.kCallingWithVoice);
    stateCallingWithVideo = machine.newState(CallingState.kCallingWithVideo);
    stateOnlineVoice = machine.newState(CallingState.kOnlineVoice);
    stateOnlineVideo = machine.newState(CallingState.kOnlineVideo);
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
    // final pageParams =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    var localUserInfo = context.read<ZegoUserService>().localUserInfo;
    //  call test
    ZegoUserInfo caller = localUserInfo;
    ZegoUserInfo callee = ZegoUserInfo('002', 'name 2', 0);
    currentState = CallingState.kCallingWithVideo;

    switch (currentState) {
      case CallingState.kIdle:
        return const SizedBox();
      case CallingState.kCallingWithVoice:
      case CallingState.kCallingWithVideo:
        var localUserIsCaller = localUserInfo.userID == caller.userID;
        var callType = currentState == CallingState.kCallingWithVideo
            ? ZegoCallType.kZegoCallTypeVideo
            : ZegoCallType.kZegoCallTypeVoice;
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
