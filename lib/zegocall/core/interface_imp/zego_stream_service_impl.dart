// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import './../../../zegocall/core/interface/zego_event_handler.dart';
import './../interface/zego_stream_service.dart';
import './../manager/zego_service_manager.dart';

class ZegoStreamServiceImpl extends IZegoStreamService with ZegoEventHandler {
  bool isCameraPublishing = false;
  Map<String, ValueChanged<bool>> userStreamReadyNotifiers = {};

  @override
  void init() {
    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  void startPreview(int viewID) {
    ZegoCanvas canvas = ZegoCanvas.view(viewID);
    canvas.viewMode = ZegoViewMode.AspectFill;

    //  bind stream to view, by stream id and view id
    ZegoExpressEngine.instance
        .startPreview(canvas: canvas, channel: ZegoPublishChannel.Main);
  }

  @override
  void startPlaying(String userID, int viewID) {
    ZegoCanvas canvas = ZegoCanvas.view(viewID);
    canvas.viewMode = ZegoViewMode.AspectFill;

    //  bind stream to view, by stream id and view id
    var streamID = generateStreamIDByUserID(userID);
    ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
  }

  @override
  void addStreamStateNotifier(String userID, ValueChanged<bool> notifier) {
    var streamID = generateStreamIDByUserID(userID);

    if (userStreamReadyNotifiers.containsKey(streamID)) {
      return;
    }

    userStreamReadyNotifiers[streamID] = notifier;
  }

  @override
  void removeStreamStateNotifier(String userID) {
    var streamID = generateStreamIDByUserID(userID);
    userStreamReadyNotifiers.remove(streamID);
  }

  @override
  void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    for (final stream in streamList) {
      if (updateType == ZegoUpdateType.Add) {
        // ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
      } else {
        ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
      }
    }
  }

  @override
  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    var streamID = generateStreamIDByUserID(
        ZegoServiceManager.shared.userService.localUserInfo.userID);
    isCameraPublishing = true;

    if (userStreamReadyNotifiers.containsKey(streamID)) {
      userStreamReadyNotifiers[streamID]!(true);
    }
  }

  @override
  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (userStreamReadyNotifiers.containsKey(streamID)) {
      final isReady = ZegoPlayerState.Playing == state;
      userStreamReadyNotifiers[streamID]!(isReady);
    }
  }

  @override
  void onApiCalledResult(int errorCode, String funcName, String info) {
    if ("enableCamera" == funcName && isCameraPublishing) {
      // close local camera
      var streamID = generateStreamIDByUserID(
          ZegoServiceManager.shared.userService.localUserInfo.userID);
      isCameraPublishing = false;

      if (userStreamReadyNotifiers.containsKey(streamID)) {
        userStreamReadyNotifiers[streamID]!(false);
      }
    }
  }
}

String generateStreamIDByUserID(String userID) {
  var roomID = ZegoServiceManager.shared.roomService.roomInfo.roomID;
  return roomID + "_" + userID + "_main";
}

String getUserIDFromStreamID(String streamID) {
  var items = streamID.split('_');
  return items.length < 2 ? "" : items[1];
}
