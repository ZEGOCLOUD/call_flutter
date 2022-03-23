import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_state.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_video_calling_frame.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_voice_calling_frame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniOverlayPage extends StatefulWidget {
  MiniOverlayPage({Key? key}) : super(key: key);

  @override
  _MiniOverlayPageState createState() => _MiniOverlayPageState();
}

class _MiniOverlayPageState extends State<MiniOverlayPage> {
  MiniOverlayPageState currentState = MiniOverlayPageState.kIdle;

  // Both of the caller and callee disable the camera while calling
  bool fromVideoToVoice = false;

  final machine = sm.Machine<MiniOverlayPageState>();
  late sm.State<MiniOverlayPageState> stateIdle;
  late sm.State<MiniOverlayPageState> stateVoiceCalling;
  late sm.State<MiniOverlayPageState> stateVideoCalling;

  void updatePageCurrentState() {
    setState(() => currentState = machine.current!.identifier);
  }

  @override
  void initState() {
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
    machine.start();
    machine.current = stateVoiceCalling; // TODO test

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getContentByCurrentState() {
      switch (currentState) {
        case MiniOverlayPageState.kIdle:
          return const SizedBox();
        case MiniOverlayPageState.kVoiceCalling:
          return Container(
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
          );
        case MiniOverlayPageState.kVideoCalling:
          return MiniOverlayVideoCallingFrame(
              waitingDuration: 10,
              onIdleStateEntry: () => stateIdle.enter(),
              onBothWithoutVideoEntry: () {
                setState(() => fromVideoToVoice = true);
                stateVoiceCalling.enter();
              });
      }
    }
  }
}
