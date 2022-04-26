// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../model/zego_user_info.dart';

mixin ZegoUserServiceDelegate {
  /// Callback for the network quality
  ///
  /// Description: Callback for the network quality, and this callback will be triggered after the stream publishing or stream playing.     ///
  /// - Parameter userID: Refers to the user ID of the stream publisher or stream subscriber.
  /// - Parameter upstreamQuality: Refers to the stream quality level.
  void onNetworkQuality(String userID, ZegoStreamQualityLevel level);

  /// Callback for changes on user state
  ///
  /// Description: This callback will be triggered when the state of the user's microphone/camera changes.
  ///
  /// - Parameter userInfo: refers to the changes on user state information
  void onUserInfoUpdate(ZegoUserInfo info);
}
