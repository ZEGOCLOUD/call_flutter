// Dart imports:

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../core/manager/zego_call_manager.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../../core/machine/zego_mini_overlay_machine.dart';
import 'zego_mini_overlay_be_invited.dart';
import 'zego_mini_video_calling_overlay.dart';
import 'zego_mini_voice_calling_overlay.dart';

class ZegoMiniOverlayPage extends StatefulWidget {
  const ZegoMiniOverlayPage({
    Key? key,
  }) : super(key: key);

  @override
  ZegoMiniOverlayPageState createState() => ZegoMiniOverlayPageState();
}

class ZegoMiniOverlayPageState extends State<ZegoMiniOverlayPage> {
  MiniOverlayPageState currentState = MiniOverlayPageState.kIdle;

  ZegoMiniOverlayMachine machine =
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

    caller =
        ZegoCallManager.shared.getLatestUser(ZegoCallManager.shared.caller);
    callee =
        ZegoCallManager.shared.getLatestUser(ZegoCallManager.shared.callee);

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.onStateChanged = (MiniOverlayPageState state) {
        setState(() {
          caller = ZegoCallManager.shared
              .getLatestUser(ZegoCallManager.shared.caller);
          callee = ZegoCallManager.shared
              .getLatestUser(ZegoCallManager.shared.callee);
          callType = ZegoCallManager.shared.currentCallType;

          currentState = state;

          updatePageState();
        });
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
                child: ZegoMiniVoiceCallingOverlay(
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
        return Container(
          width: 200.w,
          height: 300.h,
          padding: EdgeInsets.all(12.0.w),
          decoration: BoxDecoration(
              color: const Color(0xffF3F4F7),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0.w),
                  bottomLeft: Radius.circular(20.0.w))),
          child: Stack(children: [
            ZegoMiniVideoCallingOverlay(
                machine: machine.videoCallingOverlayMachine,
                caller: caller,
                callee: callee),
            GestureDetector(
              onTap: () {
                ZegoCallManager.shared.onMiniOverlayRestore();
              },
              child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity),
            )
          ]),
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
                    ZegoMiniOverlayBeInvite(caller: caller, callType: callType)));
    }
  }

  void updatePageState() {
    switch (currentState) {
      case MiniOverlayPageState.kIdle:
        updatePagePropsState(false, const Point(0, 0), const Size(0, 0));
        break;
      case MiniOverlayPageState.kVoiceCalling:
        updatePagePropsState(true, Point(594.w, 950.h), Size(156.w, 300.h));
        break;
      case MiniOverlayPageState.kVideoCalling:
        updatePagePropsState(true, Point(593.w, 903.h), Size(157.w, 261.h));
        break;
      case MiniOverlayPageState.kBeInvite:
        updatePagePropsState(true, Point(16.w, 60.h), Size(718.w, 160.h));
        break;
    }
  }

  void updatePagePropsState(bool visibility, Point<double> topLeft, Size size) {
    setState(() {
      overlayVisibility = visibility;
      overlayTopLeftPos = Offset(topLeft.x, topLeft.y);
      overlaySize = size;
    });
  }
}