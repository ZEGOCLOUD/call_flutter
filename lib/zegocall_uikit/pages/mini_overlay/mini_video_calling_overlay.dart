// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../zegocall/core/manager/zego_service_manager.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../core/machine/mini_video_calling_overlay_machine.dart';
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
    var localUser = ZegoServiceManager.shared.userService.localUserInfo;
    var remoteUser = localUser.userID == widget.callee.userID
        ? widget.caller
        : widget.callee;

    switch (currentState) {
      case MiniVideoCallingOverlayState.kIdle:
      case MiniVideoCallingOverlayState.kWaiting:
        return const SizedBox();
      case MiniVideoCallingOverlayState.kBothWithoutVideo:
        return const SizedBox();
      case MiniVideoCallingOverlayState.kLocalUserWithVideo:
        return createVideoView(VideoPlayerView(
            userID: localUser.userID, userName: localUser.userName));
      case MiniVideoCallingOverlayState.kRemoteUserWithVideo:
        return createVideoView(VideoPlayerView(
            userID: remoteUser.userID, userName: remoteUser.userName));
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
