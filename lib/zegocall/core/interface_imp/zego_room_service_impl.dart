// Package imports:
import 'package:zego_call_flutter/zegocall/core/interface_imp/zego_stream_service_impl.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/interface/zego_event_handler.dart';
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import '../interface/zego_room_service.dart';

class ZegoRoomServiceImpl extends IZegoRoomService with ZegoEventHandler {
  ZegoRoomServiceImpl() {
    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  Future<int> joinRoom(String roomID, String token) async {
    var localUserInfo = ZegoServiceManager.shared.userService.localUserInfo;
    if (localUserInfo.userID.isEmpty) {
      return -1;
    }

    //  call test
    token = "04AAAAAGI+14sAEEA3w3mYVYquqWbKCtSJwt4AgJsEEWk8/l64adBsuW+jxEM"
        "/PGdcPPbgkO+iqhy0JXo7sJDPGP2Mxiw+gdRNmwbywyOuFeEW5bOLgeV78dji/MlH0IS3q2f/Lmj1/gQn42JsykFo8aiupDRsS4VWz/Eu6ABKzqeu6W7Kv89qoo8dqzzoPs3urU2dGP7gkH+kkzvp";

    roomInfo.roomID = roomID;

    // login rtc room
    var config = ZegoRoomConfig.defaultConfig();
    config.token = token;
    config.isUserStatusNotify = true;
    ZegoExpressEngine.instance.loginRoom(
        roomInfo.roomID, ZegoUser(localUserInfo.userID, localUserInfo.userName),
        config: config);

    // start publish
    ZegoExpressEngine.instance
        .startPublishingStream(generateStreamIDByUserID(localUserInfo.userID));

    return 0;
  }

  @override
  void leaveRoom() async {
    ZegoExpressEngine.instance.logoutRoom();
  }

  @override
  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond) async {
    var result = await ZegoServiceManager.shared.userService
        .getToken(ZegoServiceManager.shared.userService.localUserInfo.userID);
    if (result.isSuccess) {
      ZegoExpressEngine.instance.renewToken(roomID, result.success as String);
    }
  }
}
