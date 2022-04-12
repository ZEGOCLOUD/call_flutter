// Dart imports:

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../../../zegocall_demo/constants/zego_page_constant.dart';
import './../../core/zego_call_manager.dart';
import './../core/machine/mini_overlay_machine.dart';
import 'mini_overlay_be_invited.dart';
import 'mini_video_calling_overlay.dart';
import 'mini_voice_calling_overlay.dart';

class MiniOverlayPage extends StatefulWidget {
  MiniOverlayPage({
    Key? key,
  }) : super(key: key);

  MiniOverlayMachine machine =
      ZegoCallManager.shared.pageHandler.miniOverlayMachine;

  @override
  _MiniOverlayPageState createState() => _MiniOverlayPageState();
}

class _MiniOverlayPageState extends State<MiniOverlayPage> {
  MiniOverlayPageState currentState = MiniOverlayPageState.kIdle;

  Size overlaySize = const Size(0, 0);
  Offset overlayTopLeftPos = const Offset(0, 0);
  bool overlayVisibility = true;

  late ZegoUserInfo caller;
  late ZegoUserInfo callee;
  ZegoCallType callType = ZegoCallType.kZegoCallTypeVoice;

  @override
  void initState() {
    super.initState();

    caller = ZegoCallManager.shared.caller ?? ZegoUserInfo.empty();
    callee = ZegoCallManager.shared.callee ?? ZegoUserInfo.empty();
    callType = ZegoCallManager.shared.currentCallType;

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      widget.machine.onStateChanged = (MiniOverlayPageState state) {
        setState(() => currentState = state);
        updatePage();
      };

      if (null != widget.machine.machine.current) {
        currentState = widget.machine.machine.current!.identifier;
      }
      updatePage();
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
              child: MiniVoiceCallingOverlay(
                machine: widget.machine.voiceCallingOverlayMachine,
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
            child: MiniVideoCallingOverlay(
              machine: widget.machine.videoCallingOverlayMachine,
              caller: caller,
              callee: callee,
            ));
      case MiniOverlayPageState.kBeInvite:
        return Container(
            width: 718.w,
            height: 160.h,
            padding: EdgeInsets.fromLTRB(24.0.w, 0.0, 24.0.w, 0.0),
            decoration: BoxDecoration(
              color: const Color(0xff333333).withOpacity(0.8),
              borderRadius: BorderRadius.all(Radius.circular(16.0.w)),
            ),
            child: MiniOverlayBeInvite(
              callerID: caller.userID,
              callerName: caller.userName,
              callType: callType,
              onEmptyClick: () {
                Navigator.pushReplacementNamed(context, PageRouteNames.calling);
              },
              onDecline: () => ZegoCallManager.shared.declineCall(),
              onAccept: () =>
                  ZegoCallManager.shared.acceptCall(caller, callType),
            ));
    }
  }

  void updatePage() {
    switch (currentState) {
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

  void updatePageDetails(bool visibility, Point<double> topLeft, Size size) {
    setState(() {
      overlayVisibility = visibility;
      overlayTopLeftPos = Offset(topLeft.x, topLeft.y);
      overlaySize = size;
    });
  }
}
