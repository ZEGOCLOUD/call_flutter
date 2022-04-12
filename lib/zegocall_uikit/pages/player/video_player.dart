// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import './../../../zegocall/core/interface/zego_device_service.dart';
import './../../../zegocall/core/interface/zego_stream_service.dart';
import './../../../zegocall/core/interface/zego_user_service.dart';
import 'avatar_background.dart';

class VideoPlayerView extends StatefulWidget {
  final String userID;
  final String userName;

  const VideoPlayerView(
      {required this.userID, required this.userName, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerViewState();
  }
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  int playingViewID = 0;
  bool isStreamReady = false;

  void onStreamReadyStateChanged(bool isReady) {
    setState(() {
      isStreamReady = isReady;
    });
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      var streamService = context.read<IZegoStreamService>();
      streamService.addStreamStateNotifier(
          widget.userID, onStreamReadyStateChanged);
    });
  }

  @override
  void dispose() {
    super.dispose();

    var streamService = context.read<IZegoStreamService>();
    streamService.removeStreamStateNotifier(widget.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: createPlayingView(context)),
        Visibility(
            visible: !isStreamReady,
            child: AvatarBackgroundView(userName: widget.userName))
      ],
    );
  }

  Widget? createPlayingView(BuildContext context) {
    return ZegoExpressEngine.instance.createPlatformView((int playingViewID) {
      playingViewID = playingViewID;

      var userService = context.read<IZegoUserService>();
      var streamService = context.read<IZegoStreamService>();

      if (userService.localUserInfo.userID == widget.userID) {
        var userInfo = userService.getUserInfoByID(widget.userID);

        var deviceService = context.read<IZegoDeviceService>();
        deviceService.enableCamera(userInfo.camera);
        deviceService.enableMic(userInfo.mic);
        deviceService.useFrontCamera(true);

        streamService.startPreview(playingViewID);
      } else {
        streamService.startPlaying(widget.userID, playingViewID);
      }
    });
  }
}
