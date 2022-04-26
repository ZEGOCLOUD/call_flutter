// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../logger.dart';
import '../../../zegocall/core/manager/zego_service_manager.dart';
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../core/machine/zego_mini_video_calling_overlay_machine.dart';
import '../player/zego_video_player.dart';

class ZegoMiniVideoCallingOverlay extends StatefulWidget {
  const ZegoMiniVideoCallingOverlay({
    required this.machine,
    required this.caller,
    required this.callee,
    Key? key,
  }) : super(key: key);

  final ZegoMiniVideoCallingOverlayMachine machine;
  final ZegoUserInfo caller;
  final ZegoUserInfo callee;

  @override
  ZegoMiniVideoCallingOverlayState createState() =>
      ZegoMiniVideoCallingOverlayState();
}

class ZegoMiniVideoCallingOverlayState
    extends State<ZegoMiniVideoCallingOverlay> {
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
    var localPlayer =
        ZegoVideoPlayer(userID: localUser.userID, userName: localUser.userName);
    var remotePlayer = ZegoVideoPlayer(
        userID: remoteUser.userID, userName: remoteUser.userName);
    switch (currentState) {
      case MiniVideoCallingOverlayState.kIdle:
      case MiniVideoCallingOverlayState.kWaiting:
        return const SizedBox();
      case MiniVideoCallingOverlayState.kBothWithoutVideo:
        return const SizedBox();
      case MiniVideoCallingOverlayState.kWithVideo:
        return createVideoView(localPlayer, remotePlayer);
    }
  }

  Widget createVideoView(
      ZegoVideoPlayer localPlayer, ZegoVideoPlayer remotePlayer) {
    return Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
                width: 133.w,
                height: 237.h,
                child: ValueListenableBuilder<bool>(
                    valueListenable: ZegoServiceManager.shared.streamService
                        .getStreamStateNotifier(remotePlayer.userID),
                    builder: (context, isRemoteUserStreamAdded, _) {
                      if (isRemoteUserStreamAdded) {
                        return ValueListenableBuilder<bool>(
                            valueListenable: ZegoServiceManager
                                .shared.streamService
                                .getCameraStateNotifier(remotePlayer.userID),
                            builder: (context, isRemoteUserCameraEnabled, _) {
                              return IndexedStack(
                                  //  must contain REMOTE user play view, otherwise
                                  //  wouldn't play remote user's stream
                                  index: isRemoteUserCameraEnabled ? 1 : 0,
                                  children: [localPlayer, remotePlayer]);
                            });
                      }
                      return localPlayer;
                    }))));
  }
}
