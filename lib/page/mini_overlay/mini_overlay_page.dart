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

  Function(double x, double y) onPosUpdateRequest;

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
  }

  void updatePagePosition() {
    // TODO @adam get pos by screen data
    if (machine.current!.identifier != MiniOverlayPageState.kBeInvite) {
      widget.onPosUpdateRequest(300, 500);
    } else {
      widget.onPosUpdateRequest(20, 20);
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
    machine.current = stateVoiceCalling; // TODO test

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (currentState) {
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
          return MiniOverlayBeInviteFrame(
            callerID: inviteInfo.userID,
            callerName: inviteInfo.displayName,
            callType: inviteCallType,
            onDecline: () => stateIdle.enter(),
            onAccept: () => stateIdle.enter(),
          );
      }
    }
  }
}
