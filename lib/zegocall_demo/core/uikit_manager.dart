// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import 'package:zego_call_flutter/zegocall_demo/core/token_manager.dart';
import '../../logger.dart';
import '../../zegocall_uikit/core/manager/zego_call_manager.dart';
import '../../zegocall_uikit/core/manager/zego_call_manager_delegate.dart';

class UIKitManager extends ChangeNotifier with ZegoCallManagerDelegate {
  static var shared = UIKitManager();

  void init() {
    ZegoCallManager.interface.delegate = this;
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
    var userID = ZegoCallManager.interface.localUserInfo?.userID ?? "";
    if (userID.isEmpty) {
      logInfo('user id is empty');
      return "";
    }

    var token = TokenManager.shared.getToken(userID);
    logInfo('get token, token:$token');
    return token;
  }

  @override
  onRoomTokenWillExpire(String roomID, int remainTimeInSecond) {
    var userID = ZegoCallManager.interface.localUserInfo?.userID ?? "";
    if (userID.isEmpty) {
      logInfo('user id is empty');
      return;
    }

    logInfo('try get token..');
    TokenManager.shared.getToken(userID).then((token) {
      logInfo('get token, $token');
      if (token.isNotEmpty) {
        ZegoCallManager.interface.renewToken(token, roomID);
      }
    });
  }
}
