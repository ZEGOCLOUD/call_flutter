// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../logger.dart';
import '../../zegocall/core/model/zego_user_info.dart';
import '../../zegocall/core/zego_call_defines.dart';
import '../../zegocall_uikit/core/manager/zego_call_manager.dart';
import '../../zegocall_uikit/core/manager/zego_call_manager_delegate.dart';
import '../../zegocall_uikit/core/manager/zego_token_provider_interface.dart';
import 'token_manager.dart';

class UIKitManager extends ChangeNotifier
    with ZegoCallManagerDelegate, ZegoTokenProviderInterface {
  static var shared = UIKitManager();

  void init() {
    ZegoCallManager.interface.delegate = this;
    ZegoCallManager.interface.setTokenProvider(this);
  }

  @override
  onReceiveCallAccepted(ZegoUserInfo callee) {}

  @override
  onReceiveCallCanceled(ZegoUserInfo caller) {}

  @override
  onReceiveCallDeclined(ZegoUserInfo userInfo, ZegoDeclineType type) {}

  @override
  onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type) {}

  @override
  onReceiveCallTimeout(ZegoCallTimeoutType type, ZegoUserInfo caller) {}

  @override
  onReceivedCallEnded() {}

  @override
  Future<String> getRTCToken() async {
    var userID = ZegoCallManager.interface.localUserInfo.userID;
    if (userID.isEmpty) {
      logInfo('user id is empty');
      return "";
    }

    var token = await TokenManager.shared.getToken(userID);
    logInfo('get token, token:$token');
    return token;
  }
}
