// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../core/manager/zego_call_manager.dart';
import './../../core/machine/zego_mini_voice_calling_overlay_machine.dart';
import './../styles.dart';

class ZegoMiniVoiceCallingOverlay extends StatefulWidget {
  const ZegoMiniVoiceCallingOverlay(
      {required this.machine,
      // this.defaultState = MiniVoiceCallingOverlayState.kIdle,
      Key? key})
      : super(key: key);

  final ZegoMiniVoiceCallingOverlayMachine machine;

  @override
  ZegoMiniVoiceCallingOverlayState createState() =>
      ZegoMiniVoiceCallingOverlayState();
}

class ZegoMiniVoiceCallingOverlayState extends State<ZegoMiniVoiceCallingOverlay> {
  MiniVoiceCallingOverlayState currentState =
      MiniVoiceCallingOverlayState.kIdle;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      widget.machine.onStateChanged = (MiniVoiceCallingOverlayState state) {
        setState(() => currentState = state);
      };

      if (null != widget.machine.machine.current) {
        widget.machine
            .onStateChanged!(widget.machine.machine.current!.identifier);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    widget.machine.onStateChanged = null;
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
            getStateTextWidget(context, currentState),
          ],
        ));
  }

  Widget getStateTextWidget(
      BuildContext context, MiniVoiceCallingOverlayState state) {
    var callID = ZegoCallManager.shared.currentCallID();
    if (MiniVoiceCallingOverlayState.kOnline == state) {
      return ValueListenableBuilder<String>(
          valueListenable: ZegoCallManager.shared.callTimeManager
              .getTimer(callID)
              .displayValueNotifier,
          builder: (context, formatCallingTime, _) {
            return Text(formatCallingTime,
                textAlign: TextAlign.center,
                style: StyleConstant.onlineCountDown);
          });
    }
    return Text(getStateText(currentState),
        style: StyleConstant.voiceCallingText);
  }

  String getStateText(MiniVoiceCallingOverlayState state) {
    var stateTextMap = {
      MiniVoiceCallingOverlayState.kIdle: "",
      MiniVoiceCallingOverlayState.kWaiting:
          AppLocalizations.of(context)!.callPageStatusCalling,
      MiniVoiceCallingOverlayState.kOnline: "00:01",
      MiniVoiceCallingOverlayState.kDeclined:
          AppLocalizations.of(context)!.callPageStatusDeclined,
      MiniVoiceCallingOverlayState.kMissed:
          AppLocalizations.of(context)!.callPageStatusMissed,
      MiniVoiceCallingOverlayState.kEnded:
          AppLocalizations.of(context)!.callPageStatusEnded,
    };

    return stateTextMap[state]!;
  }
}
