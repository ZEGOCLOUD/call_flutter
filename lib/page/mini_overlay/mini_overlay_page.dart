import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_be_invite_frame.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_state.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_video_calling_frame.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_voice_calling_frame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/zego_user_info.dart';
import '../../service/zego_call_service.dart';

class MiniOverlayPage extends StatefulWidget {
  MiniOverlayPage({Key? key, required this.onPosUpdateRequest})
      : super(key: key);

  Function(bool visibility, Point<double> topLeft, Size size)
  onPosUpdateRequest;

  @override
  _MiniOverlayPageState createState() => _MiniOverlayPageState();
}

class _MiniOverlayPageState extends State<MiniOverlayPage> {
  MiniOverlayPageState currentState = MiniOverlayPageState.kIdle;

  // Both of the caller and callee disable the camera while calling
  bool fromVideoToVoice = false;
  ZegoUserInfo inviteInfo = ZegoUserInfo.empty();
  ZegoCallType inviteCallType = ZegoCallType.kZegoCallTypeVoice;

  final machine = sm.Machine<MiniOverlayPageState>();
  late sm.State<MiniOverlayPageState> stateIdle;
  late sm.State<MiniOverlayPageState> stateVoiceCalling;
  late sm.State<MiniOverlayPageState> stateVideoCalling;
  late sm.State<MiniOverlayPageState> stateBeInvite;

  void updatePageCurrentState() {
    setState(() => currentState = machine.current!.identifier);
    updatePageDetails();
  }

  void updatePageDetails() {
    switch (machine.current!.identifier) {
      case MiniOverlayPageState.kIdle:
        //  TODO test
        widget.onPosUpdateRequest(
            false, const Point(10, 10), const Size(100, 100));
        // widget.onPosUpdateRequest(
        //     false, const Point(0, 0), const Size(0, 0));
        break;
      case MiniOverlayPageState.kVoiceCalling:
        widget.onPosUpdateRequest(
            true, Point(594.w, 1058.h), Size(156.w, 156.h));
        break;
      case MiniOverlayPageState.kVideoCalling:
        widget.onPosUpdateRequest(
            true, Point(593.w, 953.h), Size(157.w, 261.h));
        break;
      case MiniOverlayPageState.kBeInvite:
        widget.onPosUpdateRequest(true, Point(16.w, 60.h), Size(718.w, 160.h));
        break;
    }
  }

  @override
  void initState() {
    // Listen on CallService event
    final callService = context.read<ZegoCallService>();
    callService.onReceiveCallInvite = (ZegoUserInfo info, ZegoCallType type) {
      setState(() {
        inviteInfo = info;
        inviteCallType = type;
      });
      stateBeInvite.enter();
    };

    machine.onAfterTransition.listen((event) {
      updatePageCurrentState();
    });
    stateIdle = machine.newState(MiniOverlayPageState.kIdle)
      ..onTimeout(const Duration(seconds: 3), () => stateVoiceCalling.enter())
      ..onEntry(() {
        setState(() => fromVideoToVoice = false);
        print("mini overlay page entry idle state...");
      });
    stateVoiceCalling = machine.newState(MiniOverlayPageState.kVoiceCalling);
    stateVideoCalling = machine.newState(MiniOverlayPageState.kVideoCalling);
    stateBeInvite = machine.newState(MiniOverlayPageState.kBeInvite)
      ..onExit(() {
        setState(() {
          inviteInfo = ZegoUserInfo.empty();
          inviteCallType = ZegoCallType.kZegoCallTypeVoice;
        });
      });
    machine.start();
    machine.current = stateIdle;

    super.initState();

    // TODO test
    Future.delayed(const Duration(seconds: 5), () {
      machine.current = stateBeInvite;
      Future.delayed(const Duration(seconds: 5), () {
        machine.current = stateIdle;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentState) {
      case MiniOverlayPageState.kIdle:
        // return const Text('');
        //  TODO test
        return const Text('IDLE',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20.0,
            ));
      case MiniOverlayPageState.kVoiceCalling:
        return Column(
          children: [
            Container(
              width: 156.w,
              height: 156.h,
              padding: EdgeInsets.all(12.0.w),
              decoration: BoxDecoration(
                color: const Color(0xffF3F4F7),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100.0.w),
                    bottomLeft: Radius.circular(100.0.w)),
              ),
              child: MiniOverlayVoiceCallingFrame(
                waitingDuration: 10,
                onIdleStateEntry: () => stateIdle.enter(),
                defaultState: fromVideoToVoice
                    ? MiniOverlayPageVoiceCallingState.kOnline
                    : MiniOverlayPageVoiceCallingState.kWaiting,
              ),
            ),
            SizedBox(
              height: 105.h,
              // 105 is voice & video position y diff to overlay page
            )
          ],
        );
      case MiniOverlayPageState.kVideoCalling:
        return Container(
            width: 157.w,
            height: 261.h,
            padding: EdgeInsets.all(12.0.w),
            decoration: BoxDecoration(
              color: const Color(0xffF3F4F7),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0.w),
                  bottomLeft: Radius.circular(20.0.w)),
            ),
            child: MiniOverlayVideoCallingFrame(
                waitingDuration: 10,
                onIdleStateEntry: () => stateIdle.enter(),
                onBothWithoutVideoEntry: () {
                  setState(() => fromVideoToVoice = true);
                  stateVoiceCalling.enter();
                }));
      case MiniOverlayPageState.kBeInvite:
        return Container(
            width: 718.w,
            height: 160.h,
            padding: EdgeInsets.fromLTRB(24.0.w, 0.0, 24.0.w, 0.0),
            decoration: BoxDecoration(
              color: const Color(0xff333333).withOpacity(0.8),
              borderRadius: BorderRadius.all(Radius.circular(16.0.w)),
            ),
            child: MiniOverlayBeInviteFrame(
              callerID: inviteInfo.userID,
              callerName: inviteInfo.displayName,
              callType: inviteCallType,
              onDecline: () => stateIdle.enter(),
              onAccept: () => stateIdle.enter(),
            ));
    }
  }
}
