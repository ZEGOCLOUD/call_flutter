// Dart imports:
import 'dart:developer';

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
  Map<String, ValueNotifier<bool>> userStreamReadyNotifiers = {};

  @override
  void init() {
    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  void startPreview(int viewID) {
    assert(ZegoServiceManager.shared.isSDKInit,
        "The SDK must be initialised first.");
    assert(!ZegoServiceManager.shared.userService.localUserInfo.isEmpty(),
        "Must be logged in first.");

    ZegoCanvas canvas = ZegoCanvas.view(viewID);
    canvas.viewMode = ZegoViewMode.AspectFill;

    //  bind stream to view, by stream id and view id
    ZegoExpressEngine.instance
        .startPreview(canvas: canvas, channel: ZegoPublishChannel.Main);
  }

  @override
  void startPlaying(String userID, int viewID) {
    assert(ZegoServiceManager.shared.isSDKInit,
        "The SDK must be initialised first.");
    assert(!ZegoServiceManager.shared.userService.localUserInfo.isEmpty(),
        "Must be logged in first.");
    assert(userID.isNotEmpty, "The user ID can not be nil.");

    ZegoCanvas canvas = ZegoCanvas.view(viewID);
    canvas.viewMode = ZegoViewMode.AspectFill;

    //  bind stream to view, by stream id and view id
    var streamID = generateStreamIDByUserID(userID);
    ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
  }

  @override
  ValueNotifier<bool> getStreamStateNotifier(String userID) {
    var streamID = generateStreamIDByUserID(userID);

    return getStreamStateNotifierByStreamID(streamID);
  }

  ValueNotifier<bool> getStreamStateNotifierByStreamID(String streamID) {
    if (!userStreamReadyNotifiers.containsKey(streamID)) {
      log('[stream service] add stream state notifier, stream id:$streamID');

      userStreamReadyNotifiers[streamID] = ValueNotifier<bool>(false);
      return userStreamReadyNotifiers[streamID]!;
    }

    return userStreamReadyNotifiers[streamID]!;
  }

  @override
  void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    log('[stream service] onRoomStreamUpdate, room id:$roomID, '
        'update type:$updateType, stream list:${streamList.toString()}, extended '
        'data:$extendedData');

    for (final stream in streamList) {
      if (updateType == ZegoUpdateType.Add) {
        // ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
      } else {
        log('[stream service] onRoomStreamUpdate, stop play '
            '${stream.streamID}');
        ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
      }
    }
  }

  @override
  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    var streamID = generateStreamIDByUserID(
        ZegoServiceManager.shared.userService.localUserInfo.userID);
    isCameraPublishing = true;

    log('[stream service] onPublisherCapturedVideoFirstFrame, stream id:$streamID');

    getStreamStateNotifierByStreamID(streamID).value = true;
  }

  @override
  void onPlayerRenderVideoFirstFrame(String streamID) {
    log('[stream service] onPlayerRenderVideoFirstFrame, stream id:$streamID');

    getStreamStateNotifierByStreamID(streamID).value = true;
  }

  @override
  void onApiCalledResult(int errorCode, String funcName, String info) {
    if ("enableCamera" == funcName && isCameraPublishing) {
      // close local camera
      var streamID = generateStreamIDByUserID(
          ZegoServiceManager.shared.userService.localUserInfo.userID);
      isCameraPublishing = false;

      log('[stream service] onApiCalledResult enable camera, stream'
          ' id:$streamID');

      getStreamStateNotifierByStreamID(streamID).value = false;
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
