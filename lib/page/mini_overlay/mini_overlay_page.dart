import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_be_invite_frame.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_state.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_video_calling_frame.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_voice_calling_frame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zego_call_flutter/model/zego_user_info.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';

class MiniOverlayPage extends StatefulWidget {
  MiniOverlayPage({Key? key}) : super(key: key);

  @override
  _MiniOverlayPageState createState() => _MiniOverlayPageState();
}

class _MiniOverlayPageState extends State<MiniOverlayPage> {
  MiniOverlayPageState currentState = MiniOverlayPageState.kIdle;

  Size overlaySize = const Size(0, 0);
  Offset overlayTopLeftPos = const Offset(0, 0);
  bool overlayVisibility = true;

  // Both of the caller and callee disable the camera while calling
  bool fromVideoToVoice = false;
  ZegoUserInfo inviteInfo = ZegoUserInfo.empty();
  ZegoCallType inviteCallType = ZegoCallType.kZegoCallTypeVoice;

  final machine = sm.Machine<MiniOverlayPageState>();
  late sm.State<MiniOverlayPageState> stateIdle;
  late sm.State<MiniOverlayPageState> stateVoiceCalling;
  late sm.State<MiniOverlayPageState> stateVideoCalling;
  late sm.State<MiniOverlayPageState> stateBeInvite;

  @override
  void initState() {
    initStateMachine();
    registerCallService();

    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: overlayVisibility,
        child: Positioned(
          left: overlayTopLeftPos.dx,
          top: overlayTopLeftPos.dy,
          child: GestureDetector(
            //  disable move
            // onPanUpdate: (d) => setState(
            //     () => overlayTopLeftPos += Offset(d.delta.dx, d.delta.dy)),
            child: SizedBox(
              width: overlaySize.width,
              height: overlaySize.height,
              child: overlayItem(),
            ),
          ),
        ));
  }

  Widget overlayItem() {
    if (null == machine.current) {
      return const Text('');
    }

    switch (machine.current!.identifier) {
      case MiniOverlayPageState.kIdle:
        return const Text('');
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
            width: 200.w,
            height: 300.h,
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

  void updatePageCurrentState() {
    setState(() => currentState = machine.current!.identifier);
    updatePage();
  }

  registerCallService() {
    // Listen on CallService event
    final callService = context.read<ZegoCallService>();
    callService.onReceiveCallInvite = (ZegoUserInfo info, ZegoCallType type) {
      if (machine.current?.identifier != MiniOverlayPageState.kIdle) {
        return;
      }
      setState(() {
        inviteInfo = info;
        inviteCallType = type;
      });
      stateBeInvite.enter();
    };
  }

  initStateMachine() {
    machine.onAfterTransition.listen((event) {
      print(
          '[state machine] mini overlay page : from ${event.source} to ${event.target}');

      updatePageCurrentState();
    });

    stateIdle = machine.newState(MiniOverlayPageState.kIdle); //  default state;
    stateVoiceCalling = machine.newState(MiniOverlayPageState.kVoiceCalling);
    stateVideoCalling = machine.newState(MiniOverlayPageState.kVideoCalling);
    stateBeInvite = machine.newState(MiniOverlayPageState.kBeInvite)
      ..onExit(() {
        setState(() {
          inviteInfo = ZegoUserInfo.empty();
          inviteCallType = ZegoCallType.kZegoCallTypeVoice;
        });
      });
  }

  void updatePage() {
    if (null == machine.current) {
      updatePageDetails(false, const Point(0, 0), const Size(0, 0));
      return;
    }

    switch (machine.current!.identifier) {
      case MiniOverlayPageState.kIdle:
        updatePageDetails(false, const Point(0, 0), const Size(0, 0));
        break;
      case MiniOverlayPageState.kVoiceCalling:
        updatePageDetails(true, Point(594.w, 950.h), Size(156.w, 156.h));
        break;
      case MiniOverlayPageState.kVideoCalling:
        updatePageDetails(true, Point(593.w, 903.h), Size(157.w, 261.h));
        break;
      case MiniOverlayPageState.kBeInvite:
        updatePageDetails(true, Point(16.w, 60.h), Size(718.w, 160.h));
        break;
    }
  }

  updatePageDetails(bool visibility, Point<double> topLeft, Size size) {
    setState(() {
      overlayVisibility = true;
      overlayTopLeftPos = Offset(topLeft.x, topLeft.y);
      overlaySize = size;
    });
  }
}
