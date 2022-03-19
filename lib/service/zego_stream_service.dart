import 'package:flutter/cupertino.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:zego_call_flutter/service/zego_room_manager.dart';

abstract class IZegoStreamService {
  void startPlaying(String userID, int playingViewID);

  Widget? createPlayingView(Function(int viewID) onViewCreated) {
    return ZegoExpressEngine.instance.createPlatformView(onViewCreated);
  }
}

class ZegoStreamService extends IZegoStreamService {

  @override
  void startPlaying(String userID, int playingViewID) {
    var streamID = _generateStreamID(userID);
    //  ZegoExpressEngine.createEngine's pros enablePlatformView should be true

    ZegoCanvas canvas = ZegoCanvas.view(playingViewID);

    if(ZegoRoomManager.shared.userService.localUserInfo.userID == userID) {
      ZegoExpressEngine.instance.startPreview(canvas: canvas, channel: ZegoPublishChannel.Main);
    } else {
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }
  }

  String _generateStreamID(String userID) {
    var roomID = ZegoRoomManager.shared.roomService.roomInfo.roomID;
    return roomID + "_" + userID + "_main";
  }
}