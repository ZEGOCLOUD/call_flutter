// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/model/zego_room_info.dart';
import './../../../zegocall/core/interface/zego_event_handler.dart';
import './../../../zegocall/core/interface_imp/zego_stream_service_impl.dart';
import './../../../zegocall/core/manager/zego_service_manager.dart';
import './../interface/zego_room_service.dart';
import './../zego_call_defines.dart';

class ZegoRoomServiceImpl extends IZegoRoomService with ZegoEventHandler {
  @override
  void init() {
    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  Future<ZegoError> joinRoom(String roomID, String token) async {
    assert(ZegoServiceManager.shared.isSDKInit,
        "The SDK must be initialised first.");
    assert(!ZegoServiceManager.shared.userService.localUserInfo.isEmpty(),
        "Must be logged in first.");

    var localUserInfo = ZegoServiceManager.shared.userService.localUserInfo;
    if (localUserInfo.userID.isEmpty) {
      return ZegoError.failed;
    }

    roomInfo.roomID = roomID;

    ZegoExpressEngine.instance.logoutRoom();

    // login rtc room
    var config = ZegoRoomConfig.defaultConfig();
    config.token = token;
    config.isUserStatusNotify = true;
    await ZegoExpressEngine.instance
        .loginRoom(roomInfo.roomID,
            ZegoUser(localUserInfo.userID, localUserInfo.userName),
            config: config)
        .then((value) {
      // start publish
      ZegoExpressEngine.instance.startPublishingStream(
          generateStreamIDByUserID(localUserInfo.userID));
    });

    return ZegoError.success;
  }

  @override
  void leaveRoom() async {
    assert(ZegoServiceManager.shared.isSDKInit,
        "The SDK must be initialised first.");
    assert(!ZegoServiceManager.shared.userService.localUserInfo.isEmpty(),
        "Must be logged in first.");

    roomInfo = ZegoRoomInfo.empty();

    ZegoExpressEngine.instance.stopPublishingStream();
    ZegoExpressEngine.instance.logoutRoom();
  }

  @override
  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond) async {
    var result = await ZegoServiceManager.shared.userService.getToken(
        ZegoServiceManager.shared.userService.localUserInfo.userID, 24 * 3600);
    if (result.isSuccess) {
      ZegoExpressEngine.instance.renewToken(roomID, result.success as String);
    }
  }
}
