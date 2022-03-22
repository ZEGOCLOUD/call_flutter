import 'package:flutter/cupertino.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:zego_call_flutter/service/zego_room_manager.dart';

abstract class IZegoStreamService {
  void startPlaying(String userID, int playingViewID);

  Widget? createPlayingView(Function(int playingViewID) onViewCreated) {
    return ZegoExpressEngine.instance.createPlatformView(onViewCreated);
  }
}

class ZegoStreamService extends IZegoStreamService {

  ZegoStreamService() {
    ZegoExpressEngine.onRoomStreamUpdate = _onRoomStreamUpdate;
    ZegoExpressEngine.onApiCalledResult = _onApiCalledResult;
    ZegoExpressEngine.onRemoteCameraStateUpdate = _onRemoteCameraStateUpdate;
    ZegoExpressEngine.onRemoteMicStateUpdate = _onRemoteMicStateUpdate;
  }


  @override
  void startPlaying(String userID, int playingViewID) {
    var streamID = _generateStreamID(userID);

    ZegoCanvas canvas = ZegoCanvas.view(playingViewID);

    if (ZegoRoomManager.shared.userService.localUserInfo.userID == userID) {
      ZegoExpressEngine.instance
          .startPreview(canvas: canvas, channel: ZegoPublishChannel.Main);
    } else {
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }
  }

  void muteMic(bool mute) {

  }

  void enableCamera(bool enable) {

  }


  String _generateStreamID(String userID) {
    var roomID = ZegoRoomManager.shared.roomService.roomInfo.roomID;
    return roomID + "_" + userID + "_main";
  }

  void _onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    for (final stream in streamList) {
      if (updateType == ZegoUpdateType.Add) {
        ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
      } else {
        ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
      }
    }
  }

  void _onApiCalledResult(int errorCode, String funcName, String info) {
    print("_onApiCalledResult funcName:$funcName, errorCode:$errorCode, info:$info");
  }

  void _onRemoteCameraStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    var tempArray = streamID.split('_');
    if (tempArray.length >= 2) {
      var uid = tempArray[1];
      var user = ZegoRoomManager.shared.userService.userDic[uid];
      user?.camera = state == ZegoRemoteDeviceState.Open;
    }
  }


  void _onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    var tempArray = streamID.split('_');
    if (tempArray.length >= 2) {
      var uid = tempArray[1];
      var user = ZegoRoomManager.shared.userService.userDic[uid];
      user?.mic = state == ZegoRemoteDeviceState.Open;
    }
  }


}
