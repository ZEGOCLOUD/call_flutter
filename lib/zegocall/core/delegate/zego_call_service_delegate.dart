// Project imports:
import '../model/zego_user_info.dart';
import '../zego_call_defines.dart';

mixin ZegoCallServiceDelegate {
  /// Callback for received a call
  ///
  /// Description: this callback will be triggered when receives a call invitation.
  ///
  /// - Parameter userInfo: the information of the caller.
  /// - Parameter type: refers to the call type, voice call or video call.
  void onReceiveCallInvited(ZegoUserInfo caller, ZegoCallType type);

  /// Callback for a call canceled
  ///
  /// Description: this callback will be triggered when a call has been cancelled.
  ///
  /// - Parameter userInfo: the information of the caller who cancels the call.
  void onReceiveCallCanceled(ZegoUserInfo caller);

  /// Callback for a call accepted
  ///
  /// Description: this callback will be triggered when a call was accepted.
  ///
  /// - Parameter userInfo: the information of the callee who accepts the call.
  void onReceiveCallAccepted(ZegoUserInfo callee);

  /// The callback for a call declined
  ///
  /// Description: this callback will be triggered when a call was declined.
  ///
  /// - Parameter userInfo: the information of the callee who declines the call.
  /// - Parameter type: the response type of the call.
  void onReceiveCallDeclined(ZegoUserInfo callee, ZegoDeclineType type);

  /// Callback for a call ended
  ///
  /// - Description: this callback will be triggered when a call has been ended.
  void onReceiveCallEnded();

  /// Callback for a call timed out
  ///
  /// - Description: this callback will be triggered when a call didn't get answered for a long time/ the caller or callee timed out during the call.
  void onReceiveCallTimeout(ZegoUserInfo caller, ZegoCallTimeoutType type);

  void onCallingStateUpdated(ZegoCallingState state);
}
