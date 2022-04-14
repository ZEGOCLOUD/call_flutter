// Dart imports:

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';

// Project imports:
import '../../core/manager/zego_call_manager.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../../core/machine/mini_overlay_machine.dart';
import 'mini_overlay_be_invited.dart';
import 'mini_video_calling_overlay.dart';
import 'mini_voice_calling_overlay.dart';

class MiniOverlayPage extends StatefulWidget {
  const MiniOverlayPage({
    Key? key,
  }) : super(key: key);

  @override
  _MiniOverlayPageState createState() => _MiniOverlayPageState();
}

class _MiniOverlayPageState extends State<MiniOverlayPage> {
  MiniOverlayPageState currentState = MiniOverlayPageState.kIdle;

  MiniOverlayMachine machine =
      ZegoCallManager.shared.pageHandler.miniOverlayMachine;

  Size overlaySize = const Size(0, 0);
  Offset overlayTopLeftPos = const Offset(0, 0);
  bool overlayVisibility = true;

  late ZegoUserInfo caller;
  late ZegoUserInfo callee;
  ZegoCallType callType = ZegoCallManager.shared.currentCallType;

  @override
  void initState() {
    super.initState();

    var userService = ZegoServiceManager.shared.userService;
    caller = userService.getUserInfoByID(ZegoCallManager.shared.callerID);
    callee = userService.getUserInfoByID(ZegoCallManager.shared.calleeID);

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.onStateChanged = (MiniOverlayPageState state) {
        setState(() {
          var userService = ZegoServiceManager.shared.userService;
          caller = userService.getUserInfoByID(ZegoCallManager.shared.callerID);
          callee = userService.getUserInfoByID(ZegoCallManager.shared.calleeID);
          callType = ZegoCallManager.shared.currentCallType;

          currentState = state;
        });
        updatePage();
      };

      if (null != machine.machine.current) {
        machine.onStateChanged!(machine.machine.current!.identifier);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    machine.onStateChanged = null;
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
              child: GestureDetector(
                onTap: () {
                  ZegoCallManager.shared.onMiniOverlayRestore();
                },
                child: MiniVoiceCallingOverlay(
                  machine: machine.voiceCallingOverlayMachine,
                ),
              ),
            ),
            SizedBox(
              height: 105.h,
              // 105 is voice & video position y diff to overlay page
            )
          ],
        );
      case MiniOverlayPageState.kVideoCalling:
        return GestureDetector(
          onTap: () {
            ZegoCallManager.shared.onMiniOverlayRestore();
          },
          child: Container(
              width: 200.w,
              height: 300.h,
              padding: EdgeInsets.all(12.0.w),
              decoration: BoxDecoration(
                  color: const Color(0xffF3F4F7),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0.w),
                      bottomLeft: Radius.circular(20.0.w))),
              child: MiniVideoCallingOverlay(
                  machine: machine.videoCallingOverlayMachine,
                  caller: caller,
                  callee: callee)),
        );
      case MiniOverlayPageState.kBeInvite:
        return GestureDetector(
            onTap: () {
              ZegoCallManager.shared.onMiniOverlayBeInvitePageEmptyClicked();
            },
            child: Container(
                width: 718.w,
                height: 160.h,
                padding: EdgeInsets.fromLTRB(24.0.w, 0.0, 24.0.w, 0.0),
                decoration: BoxDecoration(
                  color: const Color(0xff333333).withOpacity(0.8),
                  borderRadius: BorderRadius.all(Radius.circular(16.0.w)),
                ),
                child:
                    MiniOverlayBeInvite(caller: caller, callType: callType)));
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
