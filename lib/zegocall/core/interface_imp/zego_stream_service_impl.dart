// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../../../logger.dart';
import '../interface/zego_event_handler.dart';
import '../interface/zego_stream_service.dart';
import '../manager/zego_service_manager.dart';

class ZegoStreamServiceImpl extends IZegoStreamService with ZegoEventHandler {
  Map<String, ValueNotifier<bool>> cameraStateNotifiers = {};
  Map<String, ValueNotifier<bool>> streamStateNotifiers = {};

  @override
  void init() {
    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  void startPreview({int viewID = -1}) {
    assert(ZegoServiceManager.shared.isSDKInit,
        "The SDK must be initialised first.");
    assert(!ZegoServiceManager.shared.userService.localUserInfo.isEmpty(),
        "Must be logged in first.");

    ZegoCanvas? canvas;
    if (viewID >= 0) {
      canvas = ZegoCanvas.view(viewID);
      canvas.viewMode = ZegoViewMode.AspectFill;
      canvas.viewMode = ZegoViewMode.AspectFill;
    }

    //  bind stream to view, by stream id and view id
    ZegoExpressEngine.instance
        .startPreview(canvas: canvas, channel: ZegoPublishChannel.Main);
  }

  @override
  void stopPreview() {
    ZegoExpressEngine.instance.stopPreview();
  }

  @override
  void startPlaying(String userID, {int viewID = -1}) {
    assert(ZegoServiceManager.shared.isSDKInit,
        "The SDK must be initialised first.");
    assert(!ZegoServiceManager.shared.userService.localUserInfo.isEmpty(),
        "Must be logged in first.");
    assert(userID.isNotEmpty, "The user ID can not be nil.");

    if (userID.isEmpty) {
      return;
    }

    ZegoCanvas? canvas;
    if (viewID >= 0) {
      canvas = ZegoCanvas.view(viewID);
      canvas.viewMode = ZegoViewMode.AspectFill;
    }

    //  bind stream to view, by stream id and view id
    var streamID = generateStreamIDByUserID(userID);
    ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
  }

  @override
  ValueNotifier<bool> getCameraStateNotifier(String userID) {
    if (userID.isEmpty) {
      assert(false, "user id is empty");
    }

    var streamID = generateStreamIDByUserID(userID);
    return getCameraStateNotifierByStreamID(streamID);
  }

  ValueNotifier<bool> getCameraStateNotifierByStreamID(String streamID) {
    if (!cameraStateNotifiers.containsKey(streamID)) {
      logInfo(
          '[stream service] add camera state notifier, stream id:$streamID');

      cameraStateNotifiers[streamID] = ValueNotifier<bool>(false);
      return cameraStateNotifiers[streamID]!;
    }

    return cameraStateNotifiers[streamID]!;
  }

  @override
  ValueNotifier<bool> getStreamStateNotifier(String userID) {
    if (userID.isEmpty) {
      assert(false, "user id is empty");
    }

    var streamID = generateStreamIDByUserID(userID);
    return getStreamStateNotifierByStreamID(streamID);
  }

  ValueNotifier<bool> getStreamStateNotifierByStreamID(String streamID) {
    if (!streamStateNotifiers.containsKey(streamID)) {
      logInfo(
          '[stream service] add stream state notifier, stream id:$streamID');

      streamStateNotifiers[streamID] = ValueNotifier<bool>(false);
      return streamStateNotifiers[streamID]!;
    }

    return streamStateNotifiers[streamID]!;
  }

  @override
  void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    logInfo(
        'room id:$roomID, update type:$updateType, extended data:$extendedData');
    for (var stream in streamList) {
      logInfo('streamList: user:${stream.user}, streamID:${stream.streamID}, '
          'extraInfo:${stream.extraInfo}');
    }

    for (final stream in streamList) {
      if (updateType == ZegoUpdateType.Add) {
        getStreamStateNotifierByStreamID(stream.streamID).value = true;
      } else {
        getStreamStateNotifierByStreamID(stream.streamID).value = false;

        logInfo('stop play ${stream.streamID}');
        ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
      }
    }
  }

  @override
  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    var streamID = generateStreamIDByUserID(
        ZegoServiceManager.shared.userService.localUserInfo.userID);

    logInfo('stream id:$streamID');

    getCameraStateNotifierByStreamID(streamID).value = true;
  }

  @override
  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    logInfo('stream id:$streamID, state:$state, error code:$errorCode, '
        'extendedData:$extendedData');
    getCameraStateNotifierByStreamID(streamID).value =
        ZegoPlayerState.NoPlay != state;
  }

  @override
  void onRemoteCameraStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    logInfo('stream id:$streamID, state:$state');

    var isRemoteCameraPublishing = ZegoRemoteDeviceState.Open == state;
    getCameraStateNotifierByStreamID(streamID).value = isRemoteCameraPublishing;
  }

  @override
  void onLocalCameraEnabled(bool enabled) {
    var streamID = generateStreamIDByUserID(
        ZegoServiceManager.shared.userService.localUserInfo.userID);

    logInfo('enable:$enabled, stream id:$streamID');

    getCameraStateNotifierByStreamID(streamID).value = enabled;
  }

  @override
  void stopPlaying(String userID) {
    var roomID = ZegoServiceManager.shared.roomService.roomInfo.roomID;
    if (roomID.isEmpty) {
      assert(false, "The room ID can not be empty");
      return;
    }

    var streamID = generateStreamIDByUserID(userID);
    logInfo('stop play $streamID');
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
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
