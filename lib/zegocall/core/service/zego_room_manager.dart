import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:zego_call_flutter/zegocall/core/service/zego_call_service.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_device_service.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_stream_service.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_loading_service.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_room_service.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_user_service.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoRoomManager extends ChangeNotifier {
  static var shared = ZegoRoomManager();

  ZegoRoomService roomService = ZegoRoomService();
  ZegoLoadingService loadingService = ZegoLoadingService();
  ZegoUserService userService = ZegoUserService();
  ZegoCallService callService = ZegoCallService();
  ZegoStreamService streamService = ZegoStreamService();
  ZegoDeviceService deviceService = ZegoDeviceService();

  _onRoomLeave() {
    // Reset all service data
    loadingService.onRoomLeave();
    roomService.onRoomLeave();
    userService.onRoomLeave();
    callService.onRoomLeave();
    streamService.onRoomLeave();
  }

  _onRoomEnter() {
    loadingService.onRoomEnter();
    roomService.onRoomEnter();
    userService.onRoomEnter();
    callService.onRoomEnter();
    streamService.onRoomEnter();
  }

  //  call test
  Future<void> initWithAPPID(
      int appID, String serverSecret, ZegoRoomCallback callback) async {
    ZegoEngineProfile profile = ZegoEngineProfile(appID, ZegoScenario.General);
    profile.enablePlatformView = true; //  for play stream with platformView
    ZegoExpressEngine.createEngineWithProfile(profile).then((value) {});

    // setup service
    roomService.roomEnterCallback = _onRoomEnter;
    roomService.roomLeaveCallback = _onRoomLeave;

    ZegoExpressEngine.onApiCalledResult = _onApiCalledResult;
    // userService.userOfflineCallback = _onRoomLeave;
    // userService.registerMemberJoinCallback(messageService.onRoomMemberJoined);
    // userService.registerMemberLeaveCallback(messageService.onRoomMemberLeave);
  }

  Future<int> uninit() async {
    ZegoExpressEngine.destroyEngine();
    return 0;
  }

  Future<int> uploadLog() async {
    return 0;
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
    if (0 != errorCode) {
      print(
          "_onApiCalledResult funcName:$funcName, errorCode:$errorCode, info:$info");
    }

    streamService.onApiCalledResult(errorCode, funcName, info);
  }
}
