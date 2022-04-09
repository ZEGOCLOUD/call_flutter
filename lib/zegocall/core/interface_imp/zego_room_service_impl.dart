// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../../../zegocall/core/interface/zego_event_handler.dart';
import '../../../zegocall/core/interface_imp/zego_stream_service_impl.dart';
import '../../../zegocall/core/manager/zego_service_manager.dart';
import '../interface/zego_room_service.dart';

class ZegoRoomServiceImpl extends IZegoRoomService with ZegoEventHandler {
  @override
  void init() {
    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  Future<int> joinRoom(String roomID, String token) async {
    var localUserInfo = ZegoServiceManager.shared.userService.localUserInfo;
    if (localUserInfo.userID.isEmpty) {
      return -1;
    }

    roomInfo.roomID = roomID;

    ZegoExpressEngine.instance.logoutRoom();

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
    var result = await ZegoServiceManager.shared.userService.getToken(
        ZegoServiceManager.shared.userService.localUserInfo.userID, 24 * 3600);
    if (result.isSuccess) {
      ZegoExpressEngine.instance.renewToken(roomID, result.success as String);
    }
  }
}
