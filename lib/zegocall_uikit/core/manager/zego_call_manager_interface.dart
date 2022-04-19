// Project imports:
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import 'zego_call_manager_delegate.dart';

/// The call status
enum ZegoCallStatus {
  /// Free
  free,

  /// Receives a call and the call waits to be answered
  wait,

  /// The call waits to be answered by the peer side
  waitAccept,

  /// Connecting
  calling,
}

mixin ZegoCallManagerInterface {
  /// The delegate instance of the call manager.
  ZegoCallManagerDelegate? delegate;

  /// The local logged-in user information.
  ZegoUserInfo? localUserInfo;

  /// Initialize the SDK
  ///
  /// Description: This method can be used to initialize the ZIM SDK and the Express-Audio SDK.
  ///
  /// Call this method at: Before you log in. We recommend you call this method when the application starts.
  ///
  /// - Parameter appID: refers to the project ID. To get this, go to ZEGOCLOUD Admin Console: https://console.zego.im/dashboard?lang=en
  void initWithAppID(int appID);

  /// The method to deinitialize the SDK
  ///
  /// Description: This method can be used to deinitialize the SDK and release the resources it occupies.
  ///
  /// Call this method at: When the SDK is no longer be used. We recommend you call this method when the application exits.
  void uninit();

  /// Set the local user info
  ///
  /// Description: this can be used to save the user information locally.
  ///
  /// Call this method at: after the login
  ///
  /// - Parameter userID: the user ID.
  /// - Parameter userName: the username.
  void setLocalUser(String userID, String userName);

  /// Clear cached data
  ///
  /// - Description: this can be used to clear data cached by the CallManager.
  ///
  /// Call this method at: when logging out from a room or being removed from a room.
  void resetCallData();

  /// Upload local logs to the ZEGOCLOUD Server
  ///
  /// Description: You can call this method to upload the local logs to the ZEGOCLOUD Server for troubleshooting when exception occurs.
  ///
  /// Call this method at: When exceptions occur
  ///
  /// - Parameter fileName: refers to the name of the file you upload. We recommend you name the file in the format of "appid_platform_timestamp".
  /// - Parameter callback: refers to the callback that be triggered when the logs are upload successfully or failed to upload logs.
  Future<int> uploadLog();

  /// Make an outbound call
  ///
  /// Description: This method can be used to initiate a call to a online user. The called user receives a notification once this method gets called. And if the call is not answered in 60 seconds, you will need to call a method to cancel the call.
  ///
  /// Call this method at: After the user login
  /// - Parameter callee: The information of the user you want to call, including the userID and userName.
  /// - Parameter type: refers to the call type.  ZegoCallTypeVoice: Voice call.  ZegoCallTypeVideo: Video call.
  /// - Parameter callback: refers to the callback for make a outbound call.
  Future<ZegoError> callUser(ZegoUserInfo callee, ZegoCallType callType);

  /// Renew token.
  ///
  /// Description: After the developer receives [onRoomTokenWillExpire], they can use this API to update the token to ensure that the subsequent RTC functions are normal.
  ///
  /// @param token The token that needs to be renew.
  /// @param roomID Room ID.
  void renewToken(String token, String roomID);
}
