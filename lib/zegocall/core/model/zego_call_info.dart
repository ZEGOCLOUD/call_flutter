import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';

class ZegoCallInfo {
  String callID = '';
  ZegoUserInfo caller = ZegoUserInfo.empty();
  List<ZegoUserInfo> callees = [];

  ZegoCallInfo.empty();
}
