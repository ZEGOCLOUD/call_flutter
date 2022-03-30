// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../interface/zego_room_service.dart';

class ZegoRoomServiceImpl extends IZegoRoomService {
  @override
  Future<int> joinRoom(String roomID, String token) async {
    //  call test
    token = "04AAAAAGI+14sAEEA3w3mYVYquqWbKCtSJwt4AgJsEEWk8/l64adBsuW+jxEM"
        "/PGdcPPbgkO+iqhy0JXo7sJDPGP2Mxiw+gdRNmwbywyOuFeEW5bOLgeV78dji/MlH0IS3q2f/Lmj1/gQn42JsykFo8aiupDRsS4VWz/Eu6ABKzqeu6W7Kv89qoo8dqzzoPs3urU2dGP7gkH+kkzvp";
    var config = ZegoRoomConfig.defaultConfig();
    config.token = token;
    config.maxMemberCount = 0;
    var user = ZegoUser("_localUserID", "_localUserName");
    ZegoExpressEngine.instance.loginRoom(roomInfo.roomID, user, config: config);
    var soundConfig = ZegoSoundLevelConfig(1000, false);
    ZegoExpressEngine.instance.startSoundLevelMonitor(config: soundConfig);

    return 0;
  }

  @override
  Future<int> leaveRoom() async {
    // ZegoExpressEngine.instance.logoutRoom(roomID);

    return 0;
  }
}
