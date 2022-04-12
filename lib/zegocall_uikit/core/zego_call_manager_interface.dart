// Project imports:
import './../../zegocall/core/model/zego_user_info.dart';
import './../../zegocall/core/zego_call_defines.dart';

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
  /// The local logged-in user information.
  ZegoUserInfo? localUserInfo;

  ZegoCallStatus currentCallStatus = ZegoCallStatus.free;
  ZegoCallType currentCallType = ZegoCallType.kZegoCallTypeVoice;

  /// The token of use to call
  String token = "";

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

  /// Get a Token
  ///
  /// Description: this method can be used to get a Token with userID.
  ///
  /// Call this method at: after the SDK initialization
  ///
  /// - Parameter callback: refers to the callback for request the Token for authentication
  Future<String> getToken(String userID, int effectiveTimeInSeconds);

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
  void uploadLog();

  /// Make an outbound call
  ///
  /// Description: This method can be used to initiate a call to a online user. The called user receives a notification once this method gets called. And if the call is not answered in 60 seconds, you will need to call a method to cancel the call.
  ///
  /// Call this method at: After the user login
  /// - Parameter callee: The information of the user you want to call, including the userID and userName.
  /// - Parameter type: refers to the call type.  ZegoCallTypeVoice: Voice call.  ZegoCallTypeVideo: Video call.
  /// - Parameter callback: refers to the callback for make a outbound call.
  Future<ZegoError> callUser(
      ZegoUserInfo callee, ZegoCallType callType);
}