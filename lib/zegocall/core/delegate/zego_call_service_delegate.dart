// Project imports:
import '../model/zego_user_info.dart';
import '../zego_call_defines.dart';

mixin ZegoCallServiceDelegate {
  void onReceiveCallInvite(ZegoUserInfo info, ZegoCallType type);

  void onReceiveCallCanceled(ZegoUserInfo info);

  void onReceiveCallAccept(ZegoUserInfo info);

  void onReceiveCallDecline(ZegoUserInfo info, ZegoDeclineType type);

  void onReceiveCallEnded();

  void onReceiveCallTimeout(ZegoUserInfo info, ZegoCallTimeoutType type);
}
