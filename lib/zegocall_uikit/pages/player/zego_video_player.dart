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

  const ZegoVideoPlayer({required this.userID, required this.userName, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ZegoVideoPlayerState();
  }
}

class ZegoVideoPlayerState extends State<ZegoVideoPlayer> {
  int playingViewID = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: createPlayingView(context)),
        ValueListenableBuilder<bool>(
          valueListenable: ZegoServiceManager.shared.streamService
              .getCameraStateNotifier(widget.userID),
          builder: (context, isStreamReady, _) {
            return Visibility(
                visible: !isStreamReady,
                child: ZegoAvatarBackgroundView(userName: widget.userName));
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    var deviceService = ZegoServiceManager.shared.deviceService;
    deviceService.enableCamera(false);
    deviceService.enableMic(false);

    var localUserInfo = ZegoServiceManager.shared.userService.localUserInfo;
    if (localUserInfo.userID == widget.userID) {
      ZegoServiceManager.shared.streamService.stopPreview();
    }
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

        ZegoServiceManager.shared.streamService.startPreview(playingViewID);
      } else {
        ZegoServiceManager.shared.streamService
            .startPlaying(widget.userID, viewID: playingViewID);
      }
    });
  }
}
