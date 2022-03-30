// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_call_flutter/zegocall/core/delegate/zego_call_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/delegate/zego_device_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/delegate/zego_room_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/delegate/zego_stream_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/delegate/zego_user_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_room_info.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../interface/zego_call_service.dart';
import '../interface/zego_device_service.dart';
import '../interface/zego_room_service.dart';
import '../interface/zego_stream_service.dart';
import '../interface/zego_user_service.dart';
import '../interface_imp/zego_call_service_impl.dart';
import '../interface_imp/zego_device_service_impl.dart';
import '../interface_imp/zego_room_service_impl.dart';
import '../interface_imp/zego_stream_service_impl.dart';
import '../interface_imp/zego_user_service_impl.dart';

class ZegoServiceManager extends ChangeNotifier {
  static var shared = ZegoServiceManager();

  IZegoRoomService roomService = ZegoRoomServiceImpl();
  IZegoUserService userService = ZegoUserServiceImpl();
  IZegoCallService callService = ZegoCallServiceImpl();
  IZegoStreamService streamService = ZegoStreamServiceImpl();
  IZegoDeviceService deviceService = ZegoDeviceServiceImpl();

  //  call test
  Future<void> initWithAPPID(int appID, String serverSecret) async {
    ZegoEngineProfile profile = ZegoEngineProfile(appID, ZegoScenario.General);
    profile.enablePlatformView = true; //  for play stream with platformView
    ZegoExpressEngine.createEngineWithProfile(profile).then((value) {});

    // ZegoExpressEngine.onApiCalledResult = _onApiCalledResult;
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

// void _onApiCalledResult(int errorCode, String funcName, String info) {
//   if (0 != errorCode) {
//     print(
//         "_onApiCalledResult funcName:$funcName, errorCode:$errorCode, info:$info");
//   }
//
//   streamService.onApiCalledResult(errorCode, funcName, info);
// }
}
