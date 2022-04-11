// Project imports:
import '../model/zego_user_info.dart';
import '../zego_call_defines.dart';

mixin ZegoCallServiceDelegate {
  void onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type);

  void onReceiveCallCanceled(ZegoUserInfo user);

  void onReceiveCallAccept(ZegoUserInfo user);

  void onReceiveCallDecline(ZegoUserInfo user, ZegoDeclineType type);

  void onReceiveCallEnded();

  void onReceiveCallTimeout(ZegoUserInfo user, ZegoCallTimeoutType type);

  void onCallingStateUpdated(ZegoCallingState state);
}
