// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import 'package:zego_call_flutter/zegocall/core/delegate/zego_call_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/interface_imp/zego_user_service_impl.dart';
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import '../../../zegocall/core/interface/zego_call_service.dart';
import '../../../zegocall/core/interface/zego_user_service.dart';
import 'calling_callee_view.dart';
import 'calling_caller_view.dart';
import 'calling_state.dart';
import 'online_video_view.dart';
import 'online_voice_view.dart';

import 'package:zego_call_flutter/zegocall/core/interface_imp'
    '/zego_call_service_impl.dart';

class CallingPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CallingPage({Key? key}) : super(key: key);

  @override
  _CallingPageState createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage>
    with ZegoCallServiceDelegate {
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
    super.initState();

    ZegoServiceManager.shared.callService.delegate = this;

    initStateMachine();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.start();

      machine.current = stateOnlineVideo; // call test
    });
  }

  @override
  void dispose() {
    super.dispose();

    ZegoServiceManager.shared.callService.delegate = null;
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

  @override
  Widget build(BuildContext context) {
    // final pageParams =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    var localUserInfo = context.read<IZegoUserService>().localUserInfo;
    //  call test
    ZegoUserInfo caller = localUserInfo;
    ZegoUserInfo callee = ZegoUserInfo('002', 'name 2');
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

  @override
  void onReceiveCallAccept(ZegoUserInfo info) {
    // TODO: implement onReceiveCallAccept
  }

  @override
  void onReceiveCallCanceled(ZegoUserInfo info) {
    stateIdle.enter();
  }

  @override
  void onReceiveCallDecline(ZegoUserInfo info, ZegoDeclineType type) {
    // TODO: implement onReceiveCallDecline
  }

  @override
  void onReceiveCallEnded() {
    stateIdle.enter();
  }

  @override
  void onReceiveCallInvite(ZegoUserInfo info, ZegoCallType type) {
    // TODO update UI info
    if (type == ZegoCallType.kZegoCallTypeVideo) {
      stateOnlineVideo.enter();
    } else {
      stateOnlineVoice.enter();
    }
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo info, ZegoCallTimeoutType type) {}
}
