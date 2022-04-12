// Project imports:
import './../../../zegocall/core/model/zego_user_info.dart';

class ZegoCallInfo {
  String callID = '';
  ZegoUserInfo caller = ZegoUserInfo.empty();
  List<ZegoUserInfo> callees = [];

  ZegoCallInfo.empty();
}
