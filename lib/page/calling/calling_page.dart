import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statemachine/statemachine.dart' as sm;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/page/calling/calling_state.dart';
import 'package:zego_call_flutter/page/calling/calling_video_frame.dart';
import 'package:zego_call_flutter/page/calling/online_video_frame.dart';
import 'package:zego_call_flutter/page/calling/online_voice_frame.dart';

import '../../model/zego_user_info.dart';
import '../../service/zego_call_service.dart';
import 'calling_voice_frame.dart';

class CallingPage extends StatefulWidget {
  // ignore: public_member_api_docs
  CallingPage({Key? key, required this.currentState}) : super(key: key);

  CallingState currentState;

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

    machine.onAfterTransition.listen((event) {
      updatePageCurrentState();
    });
    stateIdle = machine.newState(CallingState.kIdle)
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
    machine.current = widget.currentState;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notificationPayload =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    print(notificationPayload);
    var callerName = notificationPayload['caller_name']!;

    getContentByCurrentState() {
      switch (currentState) {
        case CallingState.kIdle:
          return const SizedBox();
        case CallingState.kCallingWithVoice:
          return CallingVoiceFrame(
              calleeName: 'calleeName', calleePhotoUrl: 'calleePhotoUrl');
        case CallingState.kCallingWithVideo:
          return CallingVideoFrame(
              calleeName: 'calleeName', calleePhotoUrl: 'calleePhotoUrl');
        case CallingState.kOnlineVoice:
          return OnlineVoiceFrame(
              calleeName: 'calleeName', calleePhotoUrl: 'calleePhotoUrl');
        case CallingState.kOnlineVideo:
          return OnlineVideoFrame(
              calleeName: 'calleeName', calleePhotoUrl: 'calleePhotoUrl');
      }
    }

    return getContentByCurrentState();
  }
}
