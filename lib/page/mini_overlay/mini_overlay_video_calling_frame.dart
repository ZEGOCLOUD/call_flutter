import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statemachine/statemachine.dart' as sm;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/zego_user_info.dart';
import '../../service/zego_call_service.dart';
import 'mini_overlay_state.dart';

class MiniOverlayVideoCallingFrame extends StatefulWidget {
  MiniOverlayVideoCallingFrame(
      {Key? key,
      required this.waitingDuration,
      required this.onIdleStateEntry,
      required this.onBothWithoutVideoEntry})
      : super(key: key);

  // The duration may change on full screen calling page
  var waitingDuration = 60;
  VoidCallback onIdleStateEntry;
  VoidCallback onBothWithoutVideoEntry;

  @override
  _MiniOverlayVoiceCallingFrameState createState() =>
      _MiniOverlayVoiceCallingFrameState();
}

class _MiniOverlayVoiceCallingFrameState
    extends State<MiniOverlayVideoCallingFrame> {
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
    // Listen on CallService event
    final callService = context.read<ZegoCallService>();
    callService.onReceiveCallEnded = () => stateIdle.enter();
    callService.onReceiveCallCancel = (ZegoUserInfo info) => stateIdle.enter();
    callService.onReceiveCallResponse =
        (ZegoUserInfo info, ZegoCallType type) =>
            stateOnlyCallerWithVideo.enter();
    callService.onReceiveCallTimeout =
        (ZegoCallTimeoutType type) => stateIdle.enter();

    // TODO check stream is callee has video

    // Update current for drive UI rebuild
    machine.onAfterTransition.listen((event) {
      updatePageCurrentState();
    });
    // Config state
    stateIdle = machine.newState(MiniOverlayPageVideoCallingState.kIdle)
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

    machine.start();
    machine.current = stateWaiting;

    super.initState();
  }

  void updatePageCurrentState() {
    try {
      setState(() => currentState = machine.current!.identifier);
    } catch (e) {
      print(e);
    }
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

  Widget createVideoView(Widget playingView) {
    return Center(
        child: Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0.w),
            bottomLeft: Radius.circular(8.0.w)),
      ),
      width: 133.w,
      height: 237.h,
      child: playingView,
    ));
  }
}