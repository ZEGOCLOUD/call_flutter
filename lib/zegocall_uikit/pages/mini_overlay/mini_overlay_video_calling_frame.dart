// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import '../../../zegocall/core/delegate/zego_call_service_delegate.dart';
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import 'mini_overlay_page_delegate_notifier.dart';
import 'mini_overlay_state.dart';

class MiniOverlayVideoCallingFrame extends StatefulWidget {
  const MiniOverlayVideoCallingFrame({
    this.waitingDuration = 60,
    required this.onIdleStateEntry,
    required this.onBothWithoutVideoEntry,
    required this.delegateNotifier,
    Key? key,
  }) : super(key: key);

  // The duration may change on full screen calling page
  final int waitingDuration;
  final VoidCallback onIdleStateEntry;
  final VoidCallback onBothWithoutVideoEntry;
  final ZegoOverlayPageDelegatePageNotifier delegateNotifier;

  @override
  _MiniOverlayVoiceCallingFrameState createState() =>
      _MiniOverlayVoiceCallingFrameState();
}

class _MiniOverlayVoiceCallingFrameState
    extends State<MiniOverlayVideoCallingFrame> with ZegoCallServiceDelegate {
  MiniOverlayPageVideoCallingState currentState =
      MiniOverlayPageVideoCallingState.kIdle;

  final machine = sm.Machine<MiniOverlayPageVideoCallingState>();
  late sm.State<MiniOverlayPageVideoCallingState> stateIdle;
  late sm.State<MiniOverlayPageVideoCallingState> stateWaiting;
  late sm.State<MiniOverlayPageVideoCallingState> stateCalleeWithVideo;
  late sm.State<MiniOverlayPageVideoCallingState> stateOnlyCallerWithVideo;
  late sm.State<MiniOverlayPageVideoCallingState> stateBothWithoutVideo;

  @override
  void initState() {
    super.initState();

    initDelegateNotifier();

    initStateMachine();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.start();
    });
  }

  @override
  void onReceiveCallAccept(ZegoUserInfo info) {
    stateOnlyCallerWithVideo.enter();
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
    // TODO: implement onReceiveCallInvite
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo info, ZegoCallTimeoutType type) {
    stateIdle.enter();
  }

  @override
  Widget build(BuildContext context) {
    switch (currentState) {
      case MiniOverlayPageVideoCallingState.kIdle:
      case MiniOverlayPageVideoCallingState.kWaiting:
        return const SizedBox();
      case MiniOverlayPageVideoCallingState.kBothWithoutVideo:
        return const SizedBox();
      case MiniOverlayPageVideoCallingState.kCalleeWithVideo:
        return createVideoView(const Text(
          'Show callee video here',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ));
      case MiniOverlayPageVideoCallingState.kOnlyCallerWithVideo:
        return createVideoView(const Text(
          'Show caller video here',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ));
    }
  }

  void initDelegateNotifier() {
    widget.delegateNotifier.onPageReceiveCallInvite = onReceiveCallInvite;
    widget.delegateNotifier.onPageReceiveCallCanceled = onReceiveCallCanceled;
    widget.delegateNotifier.onPageReceiveCallAccept = onReceiveCallAccept;
    widget.delegateNotifier.onPageReceiveCallDecline = onReceiveCallDecline;
    widget.delegateNotifier.onPageReceiveCallEnded = onReceiveCallEnded;
    widget.delegateNotifier.onPageReceiveCallTimeout = onReceiveCallTimeout;
  }

  void initStateMachine() {
    // Update current for drive UI rebuild
    machine.onAfterTransition.listen((event) {
      log('[state machine] mini overlay video : from ${event.source} to '
          '${event.target}');

      updatePageCurrentState();
    });

    // Config state
    stateIdle = machine.newState(MiniOverlayPageVideoCallingState.kIdle) //
      // default state
      ..onEntry(widget.onIdleStateEntry);
    stateWaiting = machine.newState(MiniOverlayPageVideoCallingState.kWaiting)
      ..onTimeout(
          Duration(seconds: widget.waitingDuration), () => stateIdle.enter());
    stateCalleeWithVideo =
        machine.newState(MiniOverlayPageVideoCallingState.kCalleeWithVideo);
    stateOnlyCallerWithVideo =
        machine.newState(MiniOverlayPageVideoCallingState.kOnlyCallerWithVideo);
    stateBothWithoutVideo = machine
        .newState(MiniOverlayPageVideoCallingState.kBothWithoutVideo)
      ..onEntry(widget.onBothWithoutVideoEntry);
  }

  void updatePageCurrentState() {
    try {
      setState(() => currentState = machine.current!.identifier);
    } catch (e) {
      log(e.toString());
    }
  }

  Widget createVideoView(Widget playingView) {
    return Center(
        child: Container(
      width: 133.w,
      height: 237.h,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0.w),
            bottomLeft: Radius.circular(8.0.w)),
      ),
      child: playingView,
    ));
  }

  @override
  void onCallingStateUpdated(ZegoCallingState state) {
  }
}
