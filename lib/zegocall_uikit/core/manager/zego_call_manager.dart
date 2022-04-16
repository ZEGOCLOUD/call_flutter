// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:zego_call_flutter/zegocall_uikit/core/manager/zego_calltime_manager.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../../../zegocall/core/delegate/zego_call_service_delegate.dart';
import '../../../zegocall/core/delegate/zego_device_service_delegate.dart';
import '../../../zegocall/core/delegate/zego_user_service_delegate.dart';
import '../../../zegocall/core/manager/zego_service_manager.dart';
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import '../../../zegocall/notification/zego_notification_manager.dart';
import '../../../zegocall/request/zego_firebase_manager.dart';
import '../page/zego_call_page_handler.dart';
import 'zego_call_manager_delegate.dart';
import 'zego_call_manager_interface.dart';

class ZegoCallManager
    with
        ZegoCallManagerInterface,
        ZegoCallServiceDelegate,
        ZegoUserServiceDelegate,
        ZegoDeviceServiceDelegate {
  static var shared = ZegoCallManager();

  ZegoUserInfo caller = ZegoUserInfo.empty();
  ZegoUserInfo callee = ZegoUserInfo.empty();
  ZegoCallManagerDelegate? delegate;

  ZegoCallTimeManager callTimeManager = ZegoCallTimeManager.empty();
  late ZegoCallPageHandler pageHandler;

  @override
  get localUserInfo => ZegoServiceManager.shared.userService.localUserInfo;

  @override
  void initWithAppID(int appID) {
    log('[call manager] init, app id:$appID');

    ZegoServiceManager.shared.initWithAPPID(appID);
    ZegoServiceManager.shared.userService.delegate = this;
    ZegoServiceManager.shared.callService.delegate = this;
    ZegoServiceManager.shared.deviceService.delegate = this;

    ZegoFireBaseManager.shared.init();
    ZegoNotificationManager.shared.init();

    pageHandler = ZegoCallPageHandler();
    pageHandler.init();
  }

  @override
  void uninit() {
    log('[call manager] uninit');

    ZegoServiceManager.shared.userService.delegate = null;
    ZegoServiceManager.shared.callService.delegate = null;
    ZegoServiceManager.shared.deviceService.delegate = null;

    ZegoNotificationManager.shared.uninit();

    ZegoServiceManager.shared.uninit();
  }

  @override
  Future<String> getToken(String userID, int effectiveTimeInSeconds) async {
    return ZegoServiceManager.shared.userService
        .getToken(userID, effectiveTimeInSeconds)
        .then((result) {
      if (result.isSuccess) {
        log('[call manager] get token, token is ${result.success}');

        return result.success as String;
      }

      log('[call manager] fail to get token');
      return "";
    });
  }

  @override
  void resetCallData() {
    log('[call manager] reset call data');

    switch (currentCallStatus) {
      case ZegoCallStatus.free:
        break;
      case ZegoCallStatus.wait:
        currentCallStatus = ZegoCallStatus.free;

        callTimeManager.stopTimer();
        ZegoNotificationManager.shared.stopRing();
        break;
      case ZegoCallStatus.waitAccept:
        cancelCall();
        break;
      case ZegoCallStatus.calling:
        cancelCall();
        break;
    }

    resetCallUserInfo();

    pageHandler.restoreToIdle();
  }

  void resetCallUserInfo() {
    caller = ZegoUserInfo.empty();
    callee = ZegoUserInfo.empty();
  }

  @override
  void setLocalUser(String userID, String userName) {
    log('[call manager] set local user, user id:$userID, user name:$userName');

    ZegoServiceManager.shared.userService.setLocalUser(userID, userName);
  }

  @override
  void uploadLog() {
    ZegoServiceManager.shared.uploadLog();
  }

  @override
  Future<ZegoError> callUser(ZegoUserInfo callee, ZegoCallType callType) async {
    log('[call manager] call user, user:${callee.toString()}, call '
        'type:${callType.string}');

    if (currentCallStatus != ZegoCallStatus.free) {
      log('[call manager] current call status is not free, $currentCallStatus}');
      return ZegoError.failed;
    }

    currentCallType = callType;
    currentCallStatus = ZegoCallStatus.waitAccept;

    caller = ZegoServiceManager.shared.userService.localUserInfo;
    this.callee = callee;

    resetDeviceConfig();

    return ZegoServiceManager.shared.callService
        .callUser(callee, token, callType, (int errorCode) {
      if (ZegoError.success.id == errorCode) {
      } else {
        currentCallStatus = ZegoCallStatus.free;

        resetCallUserInfo();
      }

      pageHandler.onCallUserExecuted(errorCode);
    });
  }

  void acceptCall(ZegoUserInfo caller, ZegoCallType callType) {
    log('[call manager] accept call, user:${caller.toString()}, call '
        'type:${callType.string}');

    currentCallType = callType;
    currentCallStatus = ZegoCallStatus.calling;

    this.caller = caller;
    callee = ZegoServiceManager.shared.userService.localUserInfo;

    resetDeviceConfig();

    pageHandler.onAcceptCallWillExecute();

    ZegoServiceManager.shared.callService.acceptCall(token, (int errorCode) {
      if (ZegoError.success.id == errorCode) {
        callTimeManager.startTimer();

        ZegoNotificationManager.shared.stopRing();
      } else {
        currentCallStatus = ZegoCallStatus.free;

        resetCallUserInfo();
      }

      pageHandler.onAcceptCallExecuted(errorCode);
    });
  }

  void declineCall() {
    log('[call manager] decline call');

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();

    pageHandler.onDeclineCallExecuted();

    callTimeManager.stopTimer();
    ZegoNotificationManager.shared.stopRing();

    ZegoServiceManager.shared.callService.declineCall();
  }

  void endCall() {
    log('[call manager] end call');

    if (ZegoServiceManager.shared.callService.status ==
        LocalUserStatus.calling) {
      currentCallStatus = ZegoCallStatus.free;
      resetCallUserInfo();

      callTimeManager.stopTimer();
      ZegoNotificationManager.shared.stopRing();

      pageHandler.onEndCallExecuted();

      ZegoServiceManager.shared.callService.endCall();
    } else {
      declineCall();
    }
  }

  void cancelCall() {
    log('[call manager] cancel call');

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();

    pageHandler.onCancelCallExecuted();

    callTimeManager.stopTimer();
    ZegoNotificationManager.shared.stopRing();

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

    pageHandler.onCallingStateUpdated(state);
  }

  @override
  void onReceiveCallAccepted(ZegoUserInfo callee) {
    log('[call manager] receive call accept, callee:${callee.toString()}');

    caller = ZegoServiceManager.shared.userService.localUserInfo;
    callee = callee;

    callTimeManager.startTimer();

    currentCallStatus = ZegoCallStatus.calling;

    pageHandler.onReceiveCallAccepted(callee);
  }

  @override
  void onReceiveCallCanceled(ZegoUserInfo caller) {
    log('[call manager] receive call canceled, caller:${caller.toString()}');

    if ((currentCallStatus == ZegoCallStatus.calling ||
            currentCallStatus == ZegoCallStatus.wait) &&
        this.caller.userID != caller.userID) {
      log('[call manager] receive call canceled, call status is not '
          'right:$currentCallStatus, and user id is different:[${this.caller.userID}, ${caller.userID}]');
      return;
    }

    ZegoNotificationManager.shared.stopRing();

    pageHandler.onReceiveCallCanceled(caller);

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();
  }

  @override
  void onReceiveCallDecline(ZegoUserInfo callee, ZegoDeclineType type) {
    log('[call manager] receive call decline, user:${callee.toString()}, '
        'type:${type.string}');

    ZegoNotificationManager.shared.stopRing();

    pageHandler.onReceiveCallDecline(callee, type);

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();
  }

  @override
  void onReceiveCallEnded() {
    log('[call manager] receive call ended');

    ZegoNotificationManager.shared.stopRing();

    pageHandler.onReceiveCallEnded();

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();
  }

  @override
  void onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type) {
    log('[call manager] receive call invite, caller:${caller.toString()}, '
        'type:${type.string}');

    if (currentCallStatus == ZegoCallStatus.calling ||
        currentCallStatus == ZegoCallStatus.wait ||
        currentCallStatus == ZegoCallStatus.waitAccept) {
      log('[call manager] receive call invite, call status is not '
          'right:$currentCallStatus');
      return;
    }

    callTimeManager.stopTimer();
    ZegoNotificationManager.shared.startRing();

    this.caller = caller;
    callee = ZegoServiceManager.shared.userService.localUserInfo;

    currentCallStatus = ZegoCallStatus.wait;
    currentCallType = type;

    pageHandler.onReceiveCallInvite(caller, type);
  }

  void onMiniOverlayBeInvitePageEmptyClicked() {
    pageHandler.onMiniOverlayBeInvitePageEmptyClicked();
  }

  void onMiniOverlayRequest() {
    log('[call manager] mini overlay request');

    pageHandler.onMiniOverlayRequest();
  }

  void onMiniOverlayRestore() {
    log('[call manager] mini overlay restore');

    pageHandler.onMiniOverlayRestore();
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo caller, ZegoCallTimeoutType type) {
    log('[call manager] receive call timeout, user:${caller.toString()}, '
        'type:${type.string}');

    switch (type) {
      case ZegoCallTimeoutType.connecting:
        if (currentCallStatus == ZegoCallStatus.wait) {
          //
        } else if (currentCallStatus == ZegoCallStatus.waitAccept) {
          //  mini update text, missed
        }
        break;
      case ZegoCallTimeoutType.calling:
        //  mini update text, ended
        break;
    }

    pageHandler.onReceiveCallTimeout(caller, type);

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();
  }

  @override
  void onAudioRouteChange(ZegoAudioRoute audioRoute) {
    log('[call manager] audio route route, audio route:$audioRoute');
  }

  @override
  void onNetworkQuality(String userID, ZegoStreamQualityLevel level) {
    //
    // log('[call manager] network quality, user id:$userID, level:$level');
  }

  @override
  void onUserInfoUpdate(ZegoUserInfo info) {
    log('[call manager] user info update, user:${info.toString()}');

    pageHandler.onUserInfoUpdate(info);
  }

  ZegoUserInfo getLatestUser(ZegoUserInfo user) {
    var queryUser =
        ZegoServiceManager.shared.userService.getUserInfoByID(user.userID);
    if (queryUser.isEmpty()) {
      return user;
    }
    return queryUser;
  }
}
