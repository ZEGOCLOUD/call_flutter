// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../zegocall/core/manager/zego_service_manager.dart';
import 'zego_avatar_background.dart';

class ZegoAudioPlayer extends StatefulWidget {
  final String remoteUserID;
  final String remoteUserName;

  const ZegoAudioPlayer(
      {required this.remoteUserID, required this.remoteUserName, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ZegoAudioPlayerState();
  }
}

class ZegoAudioPlayerState extends State<ZegoAudioPlayer> {
  @override
  Widget build(BuildContext context) {
    return ZegoAvatarBackgroundView(userName: widget.remoteUserName);
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
