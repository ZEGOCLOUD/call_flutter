// Project imports:
import '../model/zego_room_info.dart';

mixin ZegoRoomServiceDelegate {
  void onRoomInfoUpdate(ZegoRoomInfo info);

  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond);
}
