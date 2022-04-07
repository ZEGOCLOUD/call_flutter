// Dart imports:

// Dart imports:
import 'dart:developer' as developer;
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import '../../../zegocall/core/delegate/zego_call_service_delegate.dart';
import '../../../zegocall/core/manager/zego_service_manager.dart';
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import 'mini_overlay_be_invite_frame.dart';
import 'mini_overlay_page_delegate_notifier.dart';
import 'mini_overlay_state.dart';
import 'mini_overlay_video_calling_frame.dart';
import 'mini_overlay_voice_calling_frame.dart';

class MiniOverlayPage extends StatefulWidget {
  const MiniOverlayPage({Key? key}) : super(key: key);

  @override
  _MiniOverlayPageState createState() => _MiniOverlayPageState();
}

class _MiniOverlayPageState extends State<MiniOverlayPage>
    with ZegoCallServiceDelegate {
  Size overlaySize = const Size(0, 0);
  Offset overlayTopLeftPos = const Offset(0, 0);
  bool overlayVisibility = true;

  // Both of the caller and callee disable the camera while calling
  bool fromVideoToVoice = false;
  ZegoUserInfo inviteUser = ZegoUserInfo.empty();
  ZegoCallType inviteCallType = ZegoCallType.kZegoCallTypeVoice;

  final machine = sm.Machine<MiniOverlayPageState>();
  late sm.State<MiniOverlayPageState> stateIdle;
  late sm.State<MiniOverlayPageState> stateVoiceCalling;
  late sm.State<MiniOverlayPageState> stateVideoCalling;
  late sm.State<MiniOverlayPageState> stateBeInvite;

  ZegoOverlayPageDelegatePageNotifier delegateNotifier =
      ZegoOverlayPageDelegatePageNotifier();

  @override
  void initState() {
    super.initState();

    ZegoServiceManager.shared.callService.delegate = this;

    initStateMachine();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.start();
    });
  }

  @override
  void dispose() {
    super.dispose();

    ZegoServiceManager.shared.callService.delegate = null;
  }

  @override
  void onReceiveCallAccept(ZegoUserInfo info) {
    if (null != delegateNotifier.onPageReceiveCallAccept) {
      delegateNotifier.onPageReceiveCallAccept!(info);
    }
  }

  @override
  void onReceiveCallCanceled(ZegoUserInfo info) {
    if (null != delegateNotifier.onPageReceiveCallCanceled) {
      delegateNotifier.onPageReceiveCallCanceled!(info);
    }
  }

  @override
  void onReceiveCallDecline(ZegoUserInfo info, ZegoDeclineType type) {
    if (null != delegateNotifier.onPageReceiveCallDecline) {
      delegateNotifier.onPageReceiveCallDecline!(info, type);
    }
  }

  @override
  void onReceiveCallEnded() {
    if (null != delegateNotifier.onPageReceiveCallEnded) {
      delegateNotifier.onPageReceiveCallEnded!();
    }
  }

  @override
  void onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type) {
    if (machine.current?.identifier != MiniOverlayPageState.kIdle) {
      return;
    }
    setState(() {
      inviteUser = caller;
      inviteCallType = type;
    });
    stateBeInvite.enter();

    if (null != delegateNotifier.onPageReceiveCallInvite) {
      delegateNotifier.onPageReceiveCallInvite!(caller, type);
    }
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo info, ZegoCallTimeoutType type) {
    if (null != delegateNotifier.onPageReceiveCallTimeout) {
      delegateNotifier.onPageReceiveCallTimeout!(info, type);
    }
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
                delegateNotifier: delegateNotifier,
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
              },
              delegateNotifier: delegateNotifier,
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
            child: MiniOverlayBeInviteFrame(
              callerID: inviteUser.userID,
              callerName: inviteUser.userName,
              callType: inviteCallType,
              onDecline: () => stateIdle.enter(),
              onAccept: () => stateIdle.enter(),
              delegateNotifier: delegateNotifier,
            ));
    }
  }

  void onMachineStateChanged(event) {
    developer.log(
        '[state machine] mini overlay page : from ${event.source} to ${event.target}');

    updatePage();
  }

  void onIdleStateEntry() {
    clearDelegateNotifier();
  }

  initStateMachine() {
    machine.onAfterTransition.listen(onMachineStateChanged);

    stateIdle = machine.newState(MiniOverlayPageState.kIdle)
      ..onEntry(onIdleStateEntry); //  default state;
    stateVoiceCalling = machine.newState(MiniOverlayPageState.kVoiceCalling);
    stateVideoCalling = machine.newState(MiniOverlayPageState.kVideoCalling);
    stateBeInvite = machine.newState(MiniOverlayPageState.kBeInvite)
      ..onExit(() {
        setState(() {
          inviteUser = ZegoUserInfo.empty();
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

  void clearDelegateNotifier() {
    delegateNotifier.onPageReceiveCallInvite = null;
    delegateNotifier.onPageReceiveCallCanceled = null;
    delegateNotifier.onPageReceiveCallAccept = null;
    delegateNotifier.onPageReceiveCallDecline = null;
    delegateNotifier.onPageReceiveCallEnded = null;
    delegateNotifier.onPageReceiveCallTimeout = null;
  }

  @override
  void onCallingStateUpdated(ZegoCallingState state) {}
}
