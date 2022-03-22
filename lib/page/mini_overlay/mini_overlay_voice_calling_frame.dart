import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statemachine/statemachine.dart' as sm;

import '../../model/zego_user_info.dart';
import '../../service/zego_call_service.dart';
import 'mini_overlay_state.dart';

class MiniOverlayVoiceCallingFrame extends StatefulWidget {
  MiniOverlayVoiceCallingFrame(
      {Key? key, required this.waitingDuration, required this.onIdleStateEntry})
      : super(key: key);

  // The duration may change on full screen calling page
  var waitingDuration = 60;
  VoidCallback onIdleStateEntry;

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
    // Listen on CallService event
    final callService = context.read<ZegoCallService>();
    callService.onReceiveCallEnded = () => stateEnded.enter();
    callService.onReceiveCallCancel =
        (ZegoUserInfo info) => stateDeclined.enter();
    callService.onReceiveCallResponse =
        (ZegoUserInfo info, ZegoCallType type) => stateOnline.enter();
    callService.onReceiveCallTimeout =
        (ZegoCallTimeoutType type) => stateMissed.enter();

    // Update current for drive UI rebuild
    machine.onAfterTransition.listen((event) {
      updatePageCurrentState();
    });
    // Config state
    stateIdle = machine.newState(MiniOverlayPageVoiceCallingState.kIdle)
      ..onEntry(widget.onIdleStateEntry);
    stateWaiting = machine.newState(MiniOverlayPageVoiceCallingState.kWaiting)
      ..onTimeout(
          Duration(seconds: widget.waitingDuration), () => stateMissed.enter());
    stateOnline = machine.newState(MiniOverlayPageVoiceCallingState.kOnline);
    stateDeclined = machine.newState(MiniOverlayPageVoiceCallingState.kDeclined)
      ..onTimeout(const Duration(seconds: 2), () => stateIdle.enter());
    stateMissed = machine.newState(MiniOverlayPageVoiceCallingState.kMissed)
      ..onTimeout(const Duration(seconds: 2), () => stateIdle.enter())
      ..onEntry(() {
        print('Missed state is entry >>>>>>>>>>>>>>>>>>>>>>>>>>>');
      });
    stateEnded = machine.newState(MiniOverlayPageVoiceCallingState.kEnded)
      ..onTimeout(const Duration(seconds: 2), () => stateIdle.enter());

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
    getContentByCurrentState() {
      switch (currentState) {
        case MiniOverlayPageVoiceCallingState.kIdle:
          return const SizedBox();
        case MiniOverlayPageVoiceCallingState.kWaiting:
          return Center(
              child: Container(
            color: Colors.cyan,
            width: 100,
            height: 50,
            child: const Text(
              'Waiting...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ));
        case MiniOverlayPageVoiceCallingState.kOnline:
          return const Text(
            '00:01',
            style: TextStyle(color: Colors.white, fontSize: 12),
          );
        case MiniOverlayPageVoiceCallingState.kDeclined:
          return const Text(
            'Declined',
            style: TextStyle(color: Colors.white, fontSize: 12),
          );
        case MiniOverlayPageVoiceCallingState.kMissed:
          return Center(
              child: Container(
            color: Colors.cyan,
            width: 100,
            height: 50,
            child: const Text(
              'Missed',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ));
        case MiniOverlayPageVoiceCallingState.kEnded:
          return const Text(
            'Ended',
            style: TextStyle(color: Colors.white, fontSize: 12),
          );
      }
    }

    return getContentByCurrentState();
  }
}
