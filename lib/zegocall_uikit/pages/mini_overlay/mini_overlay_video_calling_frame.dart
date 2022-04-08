// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import 'mini_overlay_state.dart';

class MiniOverlayVideoCallingFrame extends StatefulWidget {
  const MiniOverlayVideoCallingFrame({
    this.waitingDuration = 60,
    required this.onIdleStateEntry,
    required this.onBothWithoutVideoEntry,
    Key? key,
  }) : super(key: key);

  // The duration may change on full screen calling page
  final int waitingDuration;
  final VoidCallback onIdleStateEntry;
  final VoidCallback onBothWithoutVideoEntry;

  @override
  _MiniOverlayVoiceCallingFrameState createState() =>
      _MiniOverlayVoiceCallingFrameState();
}

class _MiniOverlayVoiceCallingFrameState
    extends State<MiniOverlayVideoCallingFrame>  {
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

    initStateMachine();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.start();
    });
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

}
