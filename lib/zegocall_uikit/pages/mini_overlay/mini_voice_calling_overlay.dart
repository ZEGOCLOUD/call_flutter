// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../../utils/styles.dart';
import './../../core/machine/mini_voice_calling_overlay_machine.dart';

class MiniVoiceCallingOverlay extends StatefulWidget {
  const MiniVoiceCallingOverlay(
      {required this.machine,
      // this.defaultState = MiniVoiceCallingOverlayState.kIdle,
      Key? key})
      : super(key: key);

  final MiniVoiceCallingOverlayMachine machine;

  @override
  _MiniVoiceCallingOverlayState createState() =>
      _MiniVoiceCallingOverlayState();
}

class _MiniVoiceCallingOverlayState extends State<MiniVoiceCallingOverlay> {
  MiniVoiceCallingOverlayState currentState =
      MiniVoiceCallingOverlayState.kIdle;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      widget.machine.onStateChanged = (MiniVoiceCallingOverlayState state) {
        setState(() => currentState = state);
      };
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

  String getStateText(MiniVoiceCallingOverlayState state) {
    var stateTextMap = {
      MiniVoiceCallingOverlayState.kIdle: "",
      MiniVoiceCallingOverlayState.kWaiting: "Waiting...",
      MiniVoiceCallingOverlayState.kOnline: "00:01 todo",
      MiniVoiceCallingOverlayState.kDeclined: "Declined",
      MiniVoiceCallingOverlayState.kMissed: "Missed",
      MiniVoiceCallingOverlayState.kEnded: "Ended",
    };

    return stateTextMap[state]!;
  }
}
