// Project imports:
import './../model/zego_user_info.dart';
import './../zego_call_defines.dart';

mixin ZegoCallServiceDelegate {
  void onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type);

  void onReceiveCallCanceled(ZegoUserInfo caller);

  void onReceiveCallAccepted(ZegoUserInfo callee);

  void onReceiveCallDecline(ZegoUserInfo callee, ZegoDeclineType type);

  void onReceiveCallEnded();

  void onReceiveCallTimeout(ZegoUserInfo caller, ZegoCallTimeoutType type);

  void onCallingStateUpdated(ZegoCallingState state);
}
