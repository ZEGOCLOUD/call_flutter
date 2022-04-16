// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import 'avatar_background.dart';

class VideoPlayer extends StatefulWidget {
  final String userID;
  final String userName;

  const VideoPlayer(
      {required this.userID, required this.userName, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerState();
  }
}

class VideoPlayerState extends State<VideoPlayer> {
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
                child: AvatarBackgroundView(userName: widget.userName));
          },
        )
      ],
    );
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
            .startPlaying(widget.userID, playingViewID);
      }
    });
  }
}
