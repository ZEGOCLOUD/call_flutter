// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import 'package:zego_call_flutter/zegocall_uikit/core/zego_call_manager_interface.dart';
import '../../zegocall/core/delegate/zego_call_service_delegate.dart';
import '../../zegocall/core/delegate/zego_device_service_delegate.dart';
import '../../zegocall/core/delegate/zego_user_service_delegate.dart';
import '../../zegocall/notification/zego_notification_manager.dart';
import '../../zegocall/request/zego_firebase_manager.dart';
import '../../zegocall_demo/core/zego_token_manager.dart';
import 'zego_call_manager_delegate.dart';

class ZegoCallManager
    with
        ZegoCallManagerInterface,
        ZegoCallServiceDelegate,
        ZegoUserServiceDelegate,
        ZegoDeviceServiceDelegate {
  static var shared = ZegoCallManager();

  ZegoUserInfo? targetUser;
  ZegoCallManagerDelegate? delegate;

  @override
  get localUserInfo => ZegoServiceManager.shared.userService.localUserInfo;

  // @override
  // set token(String value) => token = value;

  @override
  Future<ZegoError> callUser(
      ZegoUserInfo targetUserInfo, ZegoCallType callType) async {
    log('[call manager] call user, user:${targetUserInfo.toString()}, call '
        'type:${callType.string}');

    if (currentCallStatus != ZegoCallStatus.free) {
      log('[call manager] current call status is not free');
      return ZegoError.failed;
    }

    currentCallStatus = ZegoCallStatus.waitAccept;
    resetDeviceConfig();

    return ZegoServiceManager.shared.callService
        .callUser(targetUserInfo, token, callType)
        .then((int errorCode) {
      if (ZegoError.success.id != errorCode) {
        targetUser = targetUserInfo;
        // todo show video player
      } else {
        currentCallStatus = ZegoCallStatus.free;
      }

      return ZegoError.success;
    });
  }

  @override
  Future<String> getToken(String userID, int effectiveTimeInSeconds) async {
    return ZegoServiceManager.shared.userService
        .getToken(userID, effectiveTimeInSeconds)
        .then((result) {
      if (result.isSuccess) {
        return result.success as String;
      }
      return "";
    });
  }

  @override
  initWithAppID(int appID) {
    log('[call manager] init, app id:$appID');

    ZegoServiceManager.shared.init();

    ZegoFireBaseManager.shared.init();
    ZegoNotificationManager.shared.init();

    ZegoServiceManager.shared.userService.delegate = this;
    ZegoServiceManager.shared.callService.delegate = this;
    ZegoServiceManager.shared.deviceService.delegate = this;

    ZegoServiceManager.shared.initWithAPPID(appID);
  }

  @override
  uninit() {
    log('[call manager] uninit');

    ZegoServiceManager.shared.userService.delegate = null;
    ZegoServiceManager.shared.callService.delegate = null;
    ZegoServiceManager.shared.deviceService.delegate = null;

    ZegoNotificationManager.shared.uninit();

    ZegoServiceManager.shared.uninit();
  }

  @override
  resetCallData() {
    log('[call manager] reset call data');

    switch (currentCallStatus) {
      case ZegoCallStatus.free:
        break;
      case ZegoCallStatus.wait:
        currentCallStatus = ZegoCallStatus.free;
        targetUser = null;
        break;
      case ZegoCallStatus.waitAccept:
        cancelCall();
        break;
      case ZegoCallStatus.calling:
        cancelCall();
        break;
    }
  }

  @override
  setLocalUser(String userID, String userName) {
    log('[call manager] set local user, user id:$userID, user name:$userName');

    ZegoServiceManager.shared.userService.setLocalUser(userID, userName);
  }

  @override
  uploadLog() {
    ZegoServiceManager.shared.uploadLog();
  }

  void acceptCall(ZegoUserInfo targetUserInfo, ZegoCallType callType) {
    log('[call manager] accept call, user:${targetUserInfo.toString()}, call '
        'type:${callType.string}');

    resetDeviceConfig();
    ZegoServiceManager.shared.callService
        .acceptCall(token)
        .then((int errorCode) {
      if (ZegoError.success.id == errorCode) {
        //
      }
    });
  }

  void declineCall() {
    log('[call manager] decline call');

    currentCallStatus = ZegoCallStatus.free;
    targetUser = null;

    ZegoServiceManager.shared.callService.declineCall();
  }

  void endCall() {
    log('[call manager] end call');

    if (ZegoServiceManager.shared.callService.status ==
        LocalUserStatus.calling) {
      ZegoServiceManager.shared.callService.endCall();
    } else {
      declineCall();
    }

    currentCallStatus = ZegoCallStatus.free;
    targetUser = null;
  }

  void cancelCall() {
    log('[call manager] cancel call');

    currentCallStatus = ZegoCallStatus.free;
    ZegoServiceManager.shared.callService.cancelCall();
  }

  void resetDeviceConfig() {
    log('[call manager] reset device config');

    ZegoServiceManager.shared.userService.localUserInfo.mic = true;
    ZegoServiceManager.shared.userService.localUserInfo.camera = true;

    ZegoServiceManager.shared.deviceService.resetDeviceConfig();
  }

  @override
  void onCallingStateUpdated(ZegoCallingState state) {
    log('[call manager] calling state updated, state:${state.string}');
  }

  @override
  void onReceiveCallAccept(ZegoUserInfo user) {
    log('[call manager] receive call accept, user:${user.toString()}');
  }

  @override
  void onReceiveCallCanceled(ZegoUserInfo user) {
    log('[call manager] receive call canceled, user:${user.toString()}');
  }

  @override
  void onReceiveCallDecline(ZegoUserInfo user, ZegoDeclineType type) {
    log('[call manager] receive call decline, user:${user.toString()}, '
        'type:${type.string}');
  }

  @override
  void onReceiveCallEnded() {
    log('[call manager] receive call ended');
  }

  @override
  void onReceiveCallInvite(ZegoUserInfo user, ZegoCallType type) {
    log('[call manager] receive call invite, user:${user.toString()}, '
        'type:${type.string}');
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo user, ZegoCallTimeoutType type) {
    log('[call manager] receive call timeout, user:${user.toString()}, '
        'type:${type.string}');
  }

  @override
  void onAudioRouteChange(ZegoAudioRoute audioRoute) {
    log('[call manager] audio route route, audio route:$audioRoute');
  }

  @override
  void onNetworkQuality(String userID, ZegoStreamQualityLevel level) {
    log('[call manager] network quality, user id:$userID, level:$level');
  }

  @override
  void onReceiveUserError(ZegoUserError error) {
    log('[call manager] receive user error, error:${error.string}');
  }

  @override
  void onUserInfoUpdate(ZegoUserInfo info) {
    log('[call manager] user info update, user:${info.toString()}');
  }
}

//  Calling Page
// @override
// void onReceiveCallCanceled(ZegoUserInfo info) {
//   stateIdle.enter();
// }

// @override
// void onReceiveCallEnded() {
//   stateIdle.enter();
// }

// @override
// void onReceiveCallInvite(ZegoUserInfo info, ZegoCallType type) {
//   // TODO update UI info
//   if (type == ZegoCallType.kZegoCallTypeVideo) {
//     stateOnlineVideo.enter();
//   } else {
//     stateOnlineVoice.enter();
//   }
// }

//--------------------
//  Mini Overlay Page
// @override
// void onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type) {
//   if (machine.current?.identifier != MiniOverlayPageState.kIdle) {
//     return;
//   }
//   setState(() {
//     inviteUser = caller;
//     inviteCallType = type;
//   });
//   stateBeInvite.enter();
//
//   if (null != delegateNotifier.onPageReceiveCallInvite) {
//     delegateNotifier.onPageReceiveCallInvite!(caller, type);
//   }
// }

//--------------------
//  Mini Overlay Voice Page
//
// @override
// void onReceiveCallAccept(ZegoUserInfo info) {
//   stateOnline.enter();
// }
//
// @override
// void onReceiveCallCanceled(ZegoUserInfo info) {
//   stateDeclined.enter();
// }
// @override
// void onReceiveCallEnded() {
//   stateEnded.enter();
// }
//
// @override
// void onReceiveCallTimeout(ZegoUserInfo info, ZegoCallTimeoutType type) {
//   stateMissed.enter();
// }

//--------------------
//  Mini Overlay Video Page
// @override
// void onReceiveCallAccept(ZegoUserInfo info) {
//   stateOnlyCallerWithVideo.enter();
// }
//
// @override
// void onReceiveCallCanceled(ZegoUserInfo info) {
//   stateIdle.enter();
// }
//
// @override
// void onReceiveCallEnded() {
//   stateIdle.enter();
// }
//
// @override
// void onReceiveCallTimeout(ZegoUserInfo info, ZegoCallTimeoutType type) {
//   stateIdle.enter();
// }
