// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'mini_overlay_state.dart';

class MiniOverlayVoiceCallingFrame extends StatefulWidget {
  const MiniOverlayVoiceCallingFrame(
      {required this.onIdleStateEntry,
      this.waitingDuration = 60,
      this.defaultState = MiniOverlayPageVoiceCallingState.kIdle,
      Key? key})
      : super(key: key);

  // The duration may change on full screen calling page
  final int waitingDuration;
  final MiniOverlayPageVoiceCallingState defaultState;
  final VoidCallback onIdleStateEntry;

  @override
  _MiniOverlayVoiceCallingFrameState createState() =>
      _MiniOverlayVoiceCallingFrameState();
}

class _MiniOverlayVoiceCallingFrameState
    extends State<MiniOverlayVoiceCallingFrame> {
  MiniOverlayPageVoiceCallingState currentState =
      MiniOverlayPageVoiceCallingState.kIdle;

  final machine = sm.Machine<MiniOverlayPageVoiceCallingState>();
  late sm.State<MiniOverlayPageVoiceCallingState> stateIdle;
  late sm.State<MiniOverlayPageVoiceCallingState> stateWaiting;
  late sm.State<MiniOverlayPageVoiceCallingState> stateOnline;
  late sm.State<MiniOverlayPageVoiceCallingState> stateDeclined;
  late sm.State<MiniOverlayPageVoiceCallingState> stateMissed;
  late sm.State<MiniOverlayPageVoiceCallingState> stateEnded;

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
    return Container(
        width: 132.w,
        height: 132.h,
        decoration: const BoxDecoration(
          color: Color(0xff0055FF),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: const AssetImage(StyleIconUrls.roomOverlayVoiceCalling),
              width: 56.w,
            ),
            Text(getStateText(currentState),
                style: StyleConstant.voiceCallingText),
          ],
        ));
  }

  void initStateMachine() {
    // Update current for drive UI rebuild
    machine.onAfterTransition.listen((event) {
      log('[state machine] mini overlay voice : from ${event.source} to '
          '${event.target}');

      updatePageCurrentState();
    });

    // Config state
    stateIdle = machine.newState(MiniOverlayPageVoiceCallingState.kIdle) //
      // default state
      ..onEntry(widget.onIdleStateEntry);
    stateWaiting = machine.newState(MiniOverlayPageVoiceCallingState.kWaiting)
      ..onTimeout(
          Duration(seconds: widget.waitingDuration), () => stateMissed.enter());
    stateOnline = machine.newState(MiniOverlayPageVoiceCallingState.kOnline);
    stateDeclined = machine.newState(MiniOverlayPageVoiceCallingState.kDeclined)
      ..onTimeout(const Duration(seconds: 2), () => stateIdle.enter());
    stateMissed = machine.newState(MiniOverlayPageVoiceCallingState.kMissed)
      ..onTimeout(const Duration(seconds: 2), () => stateIdle.enter());
    stateEnded = machine.newState(MiniOverlayPageVoiceCallingState.kEnded)
      ..onTimeout(const Duration(seconds: 2), () => stateIdle.enter());

    machine.current = widget.defaultState;
  }

  void updatePageCurrentState() {
    try {
      setState(() => currentState = machine.current!.identifier);
    } catch (e) {
      log(e.toString());
    }
  }

  String getStateText(MiniOverlayPageVoiceCallingState state) {
    var stateTextMap = {
      MiniOverlayPageVoiceCallingState.kIdle: "",
      MiniOverlayPageVoiceCallingState.kWaiting: "Waiting...",
      MiniOverlayPageVoiceCallingState.kOnline: "00:01 todo",
      MiniOverlayPageVoiceCallingState.kDeclined: "Declined",
      MiniOverlayPageVoiceCallingState.kMissed: "Missed",
      MiniOverlayPageVoiceCallingState.kEnded: "Ended",
    };

    return stateTextMap[state]!;
  }
}
