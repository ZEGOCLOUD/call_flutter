import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_state.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_voice_calling_frame.dart';

class MiniOverlayPage extends StatefulWidget {
  MiniOverlayPage({Key? key}) : super(key: key);

  @override
  _MiniOverlayPageState createState() => _MiniOverlayPageState();
}

class _MiniOverlayPageState extends State<MiniOverlayPage> {
  MiniOverlayPageState currentState = MiniOverlayPageState.kIdle;

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
      ..onTimeout(const Duration(seconds: 3),
          () => stateVoiceCalling.enter())
      ..onEntry(() {
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
          return MiniOverlayVoiceCallingFrame(
              waitingDuration: 10,
              onIdleStateEntry: () {
                stateIdle.enter();
              });
        case MiniOverlayPageState.kVideoCalling:
          return Container(
            color: Colors.blue,
            width: 100,
            height: 100,
          );
      }
    }

    return Container(
      width: 100,
      height: 100,
      color: Colors.grey,
      child: SizedBox(
        width: 100,
        height: 200,
        child: getContentByCurrentState(),
      ),
    );
  }
}
