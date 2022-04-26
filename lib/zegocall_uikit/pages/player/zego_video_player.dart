// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../../../zegocall/core/manager/zego_service_manager.dart';
import 'zego_avatar_background.dart';

class ZegoVideoPlayer extends StatefulWidget {
  final String userID;
  final String userName;

  const ZegoVideoPlayer(
      {required this.userID, required this.userName, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ZegoVideoPlayerState();
  }
}

class ZegoVideoPlayerState extends State<ZegoVideoPlayer> {
  int playingViewID = 0;
  bool pendingRemoteUserStream = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: createPlayingView(context)),
        ValueListenableBuilder<bool>(
          valueListenable: ZegoServiceManager.shared.streamService
              .getCameraStateNotifier(widget.userID),
          builder: (context, isCameraEnabled, _) {
            if (pendingRemoteUserStream) {
              ZegoServiceManager.shared.streamService
                  .startPlaying(widget.userID, viewID: playingViewID);

              pendingRemoteUserStream = false;
            }
            return Visibility(
                visible: !isCameraEnabled,
                child: ZegoAvatarBackgroundView(userName: widget.userName));
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget? createPlayingView(BuildContext context) {
    return ZegoExpressEngine.instance.createPlatformView((int playingViewID) {
      this.playingViewID = playingViewID;

      var localUserInfo = ZegoServiceManager.shared.userService.localUserInfo;
      if (localUserInfo.userID == widget.userID) {
        var deviceService = ZegoServiceManager.shared.deviceService;
        deviceService.enableCamera(localUserInfo.camera);
        deviceService.enableMic(localUserInfo.mic);
        deviceService.useFrontCamera(true);

        ZegoServiceManager.shared.streamService
            .startPreview(viewID: playingViewID);
      } else {
        if (ZegoServiceManager.shared.userService
            .getUserInfoByID(widget.userID)
            .isEmpty()) {
          //  user is not in room, should play after him enter
          pendingRemoteUserStream = true;
        } else {
          ZegoServiceManager.shared.streamService
              .startPlaying(widget.userID, viewID: playingViewID);
        }
      }
    });
  }
}
