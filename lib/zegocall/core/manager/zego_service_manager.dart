// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../../../logger.dart';
import '../zego_call_defines.dart';
import './../../../zegocall/core/commands/zego_init_command.dart';
import './../interface/zego_call_service.dart';
import './../interface/zego_device_service.dart';
import './../interface/zego_event_handler.dart';
import './../interface/zego_room_service.dart';
import './../interface/zego_stream_service.dart';
import './../interface/zego_user_service.dart';
import './../interface_imp/zego_call_service_impl.dart';
import './../interface_imp/zego_device_service_impl.dart';
import './../interface_imp/zego_room_service_impl.dart';
import './../interface_imp/zego_stream_service_impl.dart';
import './../interface_imp/zego_user_service_impl.dart';

class ZegoServiceManager extends ChangeNotifier {
  static var shared = ZegoServiceManager();

  bool isSDKInit = false;

  late IZegoRoomService roomService;
  late IZegoUserService userService;
  late IZegoCallService callService;
  late IZegoStreamService streamService;
  late IZegoDeviceService deviceService;

  List<ZegoEventHandler> rtcEventDelegates = [];

  Future<void> initWithAPPID(int appID) async {
    logInfo('app id:$appID');

    createServices();
    registerExpressEventHandle();

    ZegoEngineProfile profile = ZegoEngineProfile(appID, ZegoScenario.General);
    profile.enablePlatformView = true; //  for play stream with platformView
    profile.scenario = ZegoScenario.Communication;
    await ZegoExpressEngine.createEngineWithProfile(profile).then((value) {});
    isSDKInit = true;

    initServices();

    var initCommand = ZegoInitCommand();
    initCommand.execute();
  }

  void createServices() {
    logInfo('create services');

    roomService = ZegoRoomServiceImpl();
    userService = ZegoUserServiceImpl();
    callService = ZegoCallServiceImpl();
    streamService = ZegoStreamServiceImpl();
    deviceService = ZegoDeviceServiceImpl();
  }

  void initServices() {
    logInfo('init services');

    roomService.init();
    userService.init();
    callService.init();
    streamService.init();
    deviceService.init();
    deviceService.setBestConfig();
  }

  void addExpressEventHandler(ZegoEventHandler handler) {
    rtcEventDelegates.add(handler);
  }

  void registerExpressEventHandle() {
    ZegoExpressEngine.onRoomStateUpdate = onRoomStateUpdate;
    ZegoExpressEngine.onRoomStreamUpdate = onRoomStreamUpdate;
    ZegoExpressEngine.onRoomUserUpdate = onRoomUserUpdate;
    ZegoExpressEngine.onRoomTokenWillExpire = onRoomTokenWillExpire;
    ZegoExpressEngine.onPlayerStateUpdate = onPlayerStateUpdate;
    ZegoExpressEngine.onPlayerRenderVideoFirstFrame =
        onPlayerRenderVideoFirstFrame;
    ZegoExpressEngine.onPublisherStateUpdate = onPublisherStateUpdate;
    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame =
        onPublisherCapturedVideoFirstFrame;
    ZegoExpressEngine.onNetworkQuality = onNetworkQuality;
    ZegoExpressEngine.onAudioRouteChange = onAudioRouteChange;
    ZegoExpressEngine.onRemoteCameraStateUpdate = onRemoteCameraStateUpdate;
    ZegoExpressEngine.onRemoteMicStateUpdate = onRemoteMicStateUpdate;
    ZegoExpressEngine.onApiCalledResult = onApiCalledResult;
  }

  Future<void> uninit() async {
    logInfo('uninit');

    isSDKInit = false;

    return await ZegoExpressEngine.destroyEngine();
  }

  Future<int> uploadLog() async {
    logInfo('upload log');

    assert(isSDKInit, "The SDK must be initialised first.");

    if (!isSDKInit) {
      return ZegoError.notInit.id;
    }

    ZegoExpressEngine.instance.uploadLog();

    return ZegoError.success.id;
  }

  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    logInfo(
        '[service manager] onRoomStateUpdate, roomID:$roomID, state:$state, '
        'errorCode:$errorCode, extendedData:$extendedData');

    for (var delegate in rtcEventDelegates) {
      delegate.onRoomStateUpdate(roomID, state, errorCode, extendedData);
    }
  }

  void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    logInfo('$roomID:roomID, updateType:$updateType, streamList:$streamList, extendedData:$extendedData');

    for (var delegate in rtcEventDelegates) {
      delegate.onRoomStreamUpdate(roomID, updateType, streamList, extendedData);
    }
  }

  void onRoomUserUpdate(
      String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {
    logInfo('roomID:$roomID, updateType:$updateType, userList:$userList');

    for (var delegate in rtcEventDelegates) {
      delegate.onRoomUserUpdate(roomID, updateType, userList);
    }
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    logInfo('streamID:$streamID, state:$state, errorCode:$errorCode, extendedData:$extendedData');

    for (var delegate in rtcEventDelegates) {
      delegate.onPlayerStateUpdate(streamID, state, errorCode, extendedData);
    }
  }

  void onPlayerRenderVideoFirstFrame(String streamID) {
    logInfo('streamID:$streamID');

    for (var delegate in rtcEventDelegates) {
      delegate.onPlayerRenderVideoFirstFrame(streamID);
    }
  }

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {
    logInfo('streamID:$streamID, state:$state, errorCode:$errorCode, extendedData:$extendedData');

    for (var delegate in rtcEventDelegates) {
      delegate.onPublisherStateUpdate(streamID, state, errorCode, extendedData);
    }
  }

  void onNetworkQuality(String userID, ZegoStreamQualityLevel upstreamQuality,
      ZegoStreamQualityLevel downstreamQuality) {
    // logInfo('userID:$userID, upstreamQuality:$upstreamQuality, downstreamQuality:$downstreamQuality');

    for (var delegate in rtcEventDelegates) {
      delegate.onNetworkQuality(userID, upstreamQuality, downstreamQuality);
    }
  }

  void onAudioRouteChange(ZegoAudioRoute audioRoute) {
    logInfo('audioRoute:$audioRoute');

    for (var delegate in rtcEventDelegates) {
      delegate.onAudioRouteChange(audioRoute);
    }
  }

  void onRemoteCameraStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    logInfo('streamID:$streamID, state:$state');

    for (var delegate in rtcEventDelegates) {
      delegate.onRemoteCameraStateUpdate(streamID, state);
    }
  }

  void onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    logInfo('streamID:$streamID, state:$state');

    for (var delegate in rtcEventDelegates) {
      delegate.onRemoteMicStateUpdate(streamID, state);
    }
  }

  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {
    logInfo('channel:$channel');

    for (var delegate in rtcEventDelegates) {
      delegate.onPublisherCapturedVideoFirstFrame(channel);
    }
  }

  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond) {
    logInfo('roomID:$roomID, remainTimeInSecond: $remainTimeInSecond');

    for (var delegate in rtcEventDelegates) {
      delegate.onRoomTokenWillExpire(roomID, remainTimeInSecond);
    }
  }

  void onApiCalledResult(int errorCode, String funcName, String info) {
    if (0 != errorCode) {
      logInfo('funcName:$funcName, errorCode:$errorCode, info:$info');
    }

    for (var delegate in rtcEventDelegates) {
      delegate.onApiCalledResult(errorCode, funcName, info);
    }
  }
}
