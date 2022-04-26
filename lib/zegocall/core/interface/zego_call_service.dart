// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../delegate/zego_call_service_delegate.dart';
import '../model/zego_call_info.dart';
import '../model/zego_user_info.dart';
import '../zego_call_defines.dart';
import 'zego_service.dart';

typedef CommandCallback = void Function(int);

abstract class IZegoCallService extends ChangeNotifier with ZegoService {
  /// callService refers to the delegate instance of call service.
  ZegoCallServiceDelegate? delegate;

  /// The status of a local user.
  LocalUserStatus status = LocalUserStatus.free;

  /// The call information.
  ZegoCallInfo callInfo = ZegoCallInfo.empty();

  /// Make an outbound call
  ///
  /// Description: This method can be used to initiate a call to a online user. The called user receives a notification once this method gets called. And if the call is not answered in 60 seconds, you will need to call a method to cancel the call.
  ///
  /// Call this method at: After the user login
  /// - Parameter userID: refers to the ID of the user you want call.
  /// - Parameter token: refers to the authentication token. To get this, see the documentation: https://docs.zegocloud.com/article/11648
  /// - Parameter type: refers to the call type.  ZegoCallTypeVoice: Voice call.  ZegoCallTypeVideo: Video call.
  /// - Parameter callback: refers to the callback for make a outbound call.
  ZegoError callUser(ZegoUserInfo callee, String token, ZegoCallType type,
      CommandCallback callback);

  /// Cancel a call
  ///
  /// Description: This method can be used to cancel a call. And the called user receives a callback when the call has been canceled.
  ///
  /// Call this method at: after the user login
  Future<ZegoError> cancelCall();

  /// Accept a call
  ///
  /// Description: This method can be used to accept a call. And the caller receives a callback when the call has been accepted by the callee.
  ///
  /// Call this method at: After the user login
  /// - Parameter callback: refers to the callback for accept a call.
  ZegoError acceptCall(String token, CommandCallback callback);

  /// Decline a call
  ///
  /// Description: This method can be used to decline a call. And the caller receives a callback when the call has been declined by the callee.
  ///
  /// Call this method at: after the user login
  Future<ZegoError> declineCall();

  /// End a call
  ///
  /// Description: This method can be used to end a call. And the called user receives a callback when the call has ended.
  ///
  /// Call this method at: after the user login
  Future<ZegoError> endCall();
}
