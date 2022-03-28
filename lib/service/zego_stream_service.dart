import 'package:flutter/cupertino.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:zego_call_flutter/service/zego_room_manager.dart';

abstract class IZegoStreamService {
  void startPlaying(String userID, int playingViewID);
}

class ZegoStreamService extends ChangeNotifier with IZegoStreamService {
  ZegoStreamService() {
    ZegoExpressEngine.onRoomStreamUpdate = _onRoomStreamUpdate;
    ZegoExpressEngine.onRemoteCameraStateUpdate = _onRemoteCameraStateUpdate;
    ZegoExpressEngine.onRemoteMicStateUpdate = _onRemoteMicStateUpdate;

    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame =
        _onPublisherCapturedVideoFirstFrame;
    // ZegoExpressEngine.onPublisherStateUpdate = _onPublisherStateUpdate;
    ZegoExpressEngine.onPlayerStateUpdate = _onPlayerStateUpdate;
  }

  bool isCameraPublishing = false;
  Map<String, ValueChanged<bool>> userStreamReadyNotifiers = {};

  onRoomLeave() {}

  onRoomEnter() {}

  addStreamStateNotifier(String userID, ValueChanged<bool> notifier) {
    var streamID = _generateStreamID(userID);

    if (userStreamReadyNotifiers.containsKey(streamID)) {
      return;
    }

    userStreamReadyNotifiers[streamID] = notifier;
  }

  removeStreamStateNotifier(String userID) {
    var streamID = _generateStreamID(userID);
    userStreamReadyNotifiers.remove(streamID);
  }

  @override
  void startPlaying(String userID, int playingViewID) {
    ZegoCanvas canvas = ZegoCanvas.view(playingViewID);
    canvas.viewMode = ZegoViewMode.AspectFill;

    //  bind stream to view, by stream id and view id
    if (ZegoRoomManager.shared.userService.localUserInfo.userID == userID) {
      ZegoExpressEngine.instance
          .startPreview(canvas: canvas, channel: ZegoPublishChannel.Main);
    } else {
      var streamID = _generateStreamID(userID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }
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

  void _onRemoteCameraStateUpdate(
      String streamID, ZegoRemoteDeviceState state) {
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

  void _onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    var streamID = _generateStreamID(
        ZegoRoomManager.shared.userService.localUserInfo.userID);
    isCameraPublishing = true;

    if (userStreamReadyNotifiers.containsKey(streamID)) {
      userStreamReadyNotifiers[streamID]!(true);
    }
  }

  // void _onPublisherStateUpdate(String streamID, ZegoPublisherState state,
  //     int errorCode, Map<String, dynamic> extendedData) {
  //   if (userStreamReadyNotifiers.containsKey(streamID)) {
  //     final isReady = ZegoPublisherState.Publishing == state;
  //     userStreamReadyNotifiers[streamID]!(isReady);
  //   }
  // }

  void _onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (userStreamReadyNotifiers.containsKey(streamID)) {
      final isReady = ZegoPlayerState.Playing == state;
      userStreamReadyNotifiers[streamID]!(isReady);
    }
  }

  void onApiCalledResult(int errorCode, String funcName, String info) {
    if ("enableCamera" == funcName && isCameraPublishing) {
      // close local camera
      var streamID = _generateStreamID(
          ZegoRoomManager.shared.userService.localUserInfo.userID);
      isCameraPublishing = false;

      if (userStreamReadyNotifiers.containsKey(streamID)) {
        userStreamReadyNotifiers[streamID]!(false);
      }
    }
  }
}
