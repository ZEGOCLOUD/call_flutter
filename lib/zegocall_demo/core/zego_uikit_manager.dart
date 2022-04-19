// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import 'package:zego_call_flutter/zegocall_demo/core/zego_token_manager.dart';
import '../../zegocall_uikit/core/manager/zego_call_manager.dart';
import '../../zegocall_uikit/core/manager/zego_call_manager_delegate.dart';

class ZegoUIKitManager extends ChangeNotifier with ZegoCallManagerDelegate {
  static var shared = ZegoUIKitManager();

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
      log('[uikit manager] get rtc token, user id is empty');
      return "";
    }

    var token = ZegoTokenManager.shared.getToken(userID);
    log('[uikit manager] get rtc token, get token, token:$token');
    return token;
  }

  @override
  onRoomTokenWillExpire(String roomID, int remainTimeInSecond) {
    var userID = ZegoCallManager.interface.localUserInfo?.userID ?? "";
    if (userID.isEmpty) {
      log('[uikit manager] onRoomTokenWillExpire, user id is empty');
      return;
    }

    log('[uikit manager] onRoomTokenWillExpire, try get token..');
    ZegoTokenManager.shared.getToken(userID).then((token) {
      log('[uikit manager] onRoomTokenWillExpire, get token, $token');
      if (token.isNotEmpty) {
        ZegoCallManager.interface.renewToken(token, roomID);
      }
    });
  }
}
