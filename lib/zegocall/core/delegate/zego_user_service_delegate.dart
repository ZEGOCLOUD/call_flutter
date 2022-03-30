// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../model/zego_user_info.dart';
import '../zego_call_defines.dart';

mixin ZegoUserServiceDelegate {
  void onUserInfoUpdate(ZegoUserInfo info);

  void onNetworkQuality(String userID, ZegoStreamQualityLevel level);

  void onReceiveUserError(ZegoUserError error);
}
