// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../zegocall/core/manager/zego_service_manager.dart';
import 'avatar_background.dart';

class AudioPlayer extends StatefulWidget {
  final String remoteUserID;
  final String remoteUserName;

  const AudioPlayer(
      {required this.remoteUserID, required this.remoteUserName, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AudioPlayerState();
  }
}

class AudioPlayerState extends State<AudioPlayer> {
  @override
  Widget build(BuildContext context) {
    return AvatarBackgroundView(userName: widget.remoteUserName);
  }

  @override
  void initState() {
    super.initState();

    var localUserInfo = ZegoServiceManager.shared.userService.localUserInfo;
    var deviceService = ZegoServiceManager.shared.deviceService;
    assert(!localUserInfo.camera);
    deviceService.enableCamera(localUserInfo.camera);
    deviceService.enableMic(localUserInfo.mic);

    ZegoServiceManager.shared.streamService.startPlaying(widget.remoteUserID);
  }

  @override
  void dispose() {
    super.dispose();

    var deviceService = ZegoServiceManager.shared.deviceService;
    deviceService.enableCamera(false);
    deviceService.enableMic(false);
  }
}
