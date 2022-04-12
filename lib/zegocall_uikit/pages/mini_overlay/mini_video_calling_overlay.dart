// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../zegocall/core/model/zego_user_info.dart';
import '../core/machine/mini_video_calling_overlay_machine.dart';
import './../player/video_player.dart';

class MiniVideoCallingOverlay extends StatefulWidget {
  const MiniVideoCallingOverlay({
    required this.machine,
    required this.caller,
    required this.callee,
    Key? key,
  }) : super(key: key);

  final MiniVideoCallingOverlayMachine machine;
  final ZegoUserInfo caller;
  final ZegoUserInfo callee;

  @override
  _MiniVideoCallingOverlayState createState() =>
      _MiniVideoCallingOverlayState();
}

class _MiniVideoCallingOverlayState extends State<MiniVideoCallingOverlay> {
  MiniVideoCallingOverlayState currentState =
      MiniVideoCallingOverlayState.kIdle;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      widget.machine.onStateChanged = (MiniVideoCallingOverlayState state) {
        setState(() => currentState = state);
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentState) {
      case MiniVideoCallingOverlayState.kIdle:
      case MiniVideoCallingOverlayState.kWaiting:
        return const SizedBox();
      case MiniVideoCallingOverlayState.kBothWithoutVideo:
        return const SizedBox();
      case MiniVideoCallingOverlayState.kCalleeWithVideo:
        return createVideoView(VideoPlayerView(
          userID: widget.callee.userID,
          userName: widget.callee.userName,
        ));
      case MiniVideoCallingOverlayState.kOnlyCallerWithVideo:
        return createVideoView(VideoPlayerView(
          userID: widget.caller.userID,
          userName: widget.caller.userName,
        ));
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
