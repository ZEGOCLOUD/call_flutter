// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../interface/zego_stream_service.dart';
import './../manager/zego_service_manager.dart';

class ZegoStreamServiceImpl extends IZegoStreamService {
  ZegoStreamServiceImpl() {
    ZegoExpressEngine.onRoomStreamUpdate = _onRoomStreamUpdate;

    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame =
        _onPublisherCapturedVideoFirstFrame;
    ZegoExpressEngine.onPlayerStateUpdate = _onPlayerStateUpdate;
  }

  bool isCameraPublishing = false;
  Map<String, ValueChanged<bool>> userStreamReadyNotifiers = {};

  @override
  void startPlaying(String userID, int playingViewID) {
    ZegoCanvas canvas = ZegoCanvas.view(playingViewID);
    canvas.viewMode = ZegoViewMode.AspectFill;

    //  bind stream to view, by stream id and view id
    if (ZegoServiceManager.shared.userService.localUserInfo.userID == userID) {
      ZegoExpressEngine.instance
          .startPreview(canvas: canvas, channel: ZegoPublishChannel.Main);
    } else {
      var streamID = _generateStreamID(userID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }
  }

  @override
  void addStreamStateNotifier(String userID, ValueChanged<bool> notifier) {
    var streamID = _generateStreamID(userID);

    if (userStreamReadyNotifiers.containsKey(streamID)) {
      return;
    }

    userStreamReadyNotifiers[streamID] = notifier;
  }

  @override
  void removeStreamStateNotifier(String userID) {
    var streamID = _generateStreamID(userID);
    userStreamReadyNotifiers.remove(streamID);
  }

  String _generateStreamID(String userID) {
    var roomID = ZegoServiceManager.shared.roomService.roomInfo.roomID;
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

  void _onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    var streamID = _generateStreamID(
        ZegoServiceManager.shared.userService.localUserInfo.userID);
    isCameraPublishing = true;

    if (userStreamReadyNotifiers.containsKey(streamID)) {
      userStreamReadyNotifiers[streamID]!(true);
    }
  }

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
          ZegoServiceManager.shared.userService.localUserInfo.userID);
      isCameraPublishing = false;

      if (userStreamReadyNotifiers.containsKey(streamID)) {
        userStreamReadyNotifiers[streamID]!(false);
      }
    }
  }
}
