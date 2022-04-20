// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../../../logger.dart';
import '../../../zegocall/core/delegate/zego_call_service_delegate.dart';
import '../../../zegocall/core/delegate/zego_device_service_delegate.dart';
import '../../../zegocall/core/delegate/zego_room_service_delegate.dart';
import '../../../zegocall/core/delegate/zego_user_service_delegate.dart';
import '../../../zegocall/core/manager/zego_service_manager.dart';
import '../../../zegocall/core/model/zego_room_info.dart';
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import '../../../zegocall/notification/zego_notification_manager.dart';
import '../../../zegocall/notification/zego_notification_ring.dart';
import '../../../zegocall/request/zego_firebase_manager.dart';
import '../../utils/zego_loading_manager.dart';
import '../../utils/zego_navigation_service.dart';
import '../page/zego_call_page_handler.dart';
import 'zego_call_manager_interface.dart';
import 'zego_calltime_manager.dart';

class ZegoCallManager
    with
        ZegoCallManagerInterface,
        ZegoCallServiceDelegate,
        ZegoUserServiceDelegate,
        ZegoRoomServiceDelegate,
        ZegoDeviceServiceDelegate {
  static ZegoCallManagerInterface interface = ZegoCallManager.shared;

  static var shared = ZegoCallManager();

  ZegoCallStatus currentCallStatus = ZegoCallStatus.free;
  ZegoCallType currentCallType = ZegoCallType.kZegoCallTypeVoice;

  ZegoUserInfo caller = ZegoUserInfo.empty();
  ZegoUserInfo callee = ZegoUserInfo.empty();

  ZegoCallingTimeManager callTimeManager = ZegoCallingTimeManager.empty();
  late ZegoCallPageHandler pageHandler;

  @override
  get localUserInfo => ZegoServiceManager.shared.userService.localUserInfo;

  @override
  void initWithAppID(int appID) {
    logInfo('app id:$appID');

    ZegoNavigationService().init();

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
    logInfo('uninit');

    ZegoServiceManager.shared.userService.delegate = null;
    ZegoServiceManager.shared.callService.delegate = null;
    ZegoServiceManager.shared.deviceService.delegate = null;

    ZegoNotificationManager.shared.uninit();

    ZegoServiceManager.shared.uninit();
  }

  @override
  void resetCallData() {
    logInfo('reset');

    switch (currentCallStatus) {
      case ZegoCallStatus.free:
        break;
      case ZegoCallStatus.wait:
        currentCallStatus = ZegoCallStatus.free;

        callTimeManager.stopTimer(currentCallID());
        ZegoNotificationRing.shared.stopRing();
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
    logInfo('user id:$userID, user name:$userName');

    ZegoServiceManager.shared.userService.setLocalUser(userID, userName);
  }

  @override
  Future<int> uploadLog() async {
    return ZegoServiceManager.shared.uploadLog();
  }

  @override
  void renewToken(String token, String roomID) {
    logInfo('token:$token, room id:$roomID');

    ZegoExpressEngine.instance.renewToken(roomID, token);
  }

  @override
  Future<ZegoError> callUser(ZegoUserInfo callee, ZegoCallType callType) async {
    logInfo('call user, user:${callee.toString()}, call '
        'type:${callType.string}');

    if (currentCallStatus != ZegoCallStatus.free) {
      logInfo('current call status is not free, $currentCallStatus}');
      return ZegoError.callStatusWrong;
    }

    currentCallType = callType;
    currentCallStatus = ZegoCallStatus.waitAccept;

    caller = ZegoServiceManager.shared.userService.localUserInfo;
    this.callee = callee;

    updateDeviceConfigInCalling();

    if (delegate == null) {
      assert(false, "delegate is null");
      return ZegoError.failed;
    }

    return delegate!.getRTCToken().then((String token) {
      if (currentCallStatus != ZegoCallStatus.waitAccept) {
        logInfo('current call status is not wait accept, '
            '$currentCallStatus}');
        return ZegoError.callStatusWrong;
      }
      if (token.isEmpty) {
        currentCallStatus = ZegoCallStatus.free;

        resetCallUserInfo();
        return ZegoError.tokenExpired;
      }

      return ZegoServiceManager.shared.callService
          .callUser(callee, token, callType, (int errorCode) {
        if (ZegoError.success.id == errorCode) {
        } else {
          currentCallStatus = ZegoCallStatus.free;

          resetCallUserInfo();
        }

        pageHandler.onCallUserExecuted(errorCode);
      });
    });
  }

  Future<ZegoError> acceptCall(
      ZegoUserInfo caller, ZegoCallType callType) async {
    logInfo('user:${caller.toString()}, call type:${callType.string}');

    currentCallType = callType;
    currentCallStatus = ZegoCallStatus.calling;

    this.caller = caller;
    callee = ZegoServiceManager.shared.userService.localUserInfo;

    updateDeviceConfigInCalling();

    pageHandler.onAcceptCallWillExecute();

    if (delegate == null) {
      assert(false, "delegate is null");
      return ZegoError.failed;
    }

    return delegate!.getRTCToken().then((String token) {
      if (currentCallStatus != ZegoCallStatus.calling) {
        logInfo('current call status is not calling, $currentCallStatus}');
        return ZegoError.callStatusWrong;
      }
      if (token.isEmpty) {
        currentCallStatus = ZegoCallStatus.free;

        resetCallUserInfo();
        return ZegoError.tokenExpired;
      }

      return ZegoServiceManager.shared.callService.acceptCall(token,
          (int errorCode) {
        if (ZegoError.success.id == errorCode) {
          callTimeManager.startTimer(currentCallID());
          ZegoNotificationRing.shared.stopRing();

          if (ZegoCallType.kZegoCallTypeVoice == currentCallType) {
            ZegoServiceManager.shared.streamService.startPlaying(caller.userID);
          }
        } else {
          currentCallStatus = ZegoCallStatus.free;

          resetCallUserInfo();
        }

        pageHandler.onAcceptCallExecuted(errorCode);
      });
    });
  }

  void declineCall() {
    logInfo('decline');

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();

    pageHandler.onDeclineCallExecuted();

    callTimeManager.stopTimer(currentCallID());
    ZegoNotificationRing.shared.stopRing();

    ZegoServiceManager.shared.callService.declineCall();
  }

  void endCall() {
    logInfo('end');

    if (ZegoServiceManager.shared.callService.status ==
        LocalUserStatus.calling) {
      currentCallStatus = ZegoCallStatus.free;
      resetCallUserInfo();

      callTimeManager.stopTimer(currentCallID());
      ZegoNotificationRing.shared.stopRing();

      pageHandler.onEndCallExecuted();

      ZegoServiceManager.shared.callService.endCall();
    } else {
      declineCall();
    }
  }

  void cancelCall() {
    logInfo('cancel');

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();

    pageHandler.onCancelCallExecuted();

    callTimeManager.stopTimer(currentCallID());
    ZegoNotificationRing.shared.stopRing();

    ZegoServiceManager.shared.callService.cancelCall();
  }

  void updateDeviceConfigInCalling() {
    logInfo('update');

    var userService = ZegoServiceManager.shared.userService;
    var deviceService = ZegoServiceManager.shared.deviceService;

    userService.localUserInfo.mic = true;
    userService.localUserInfo.camera =
        ZegoCallType.kZegoCallTypeVoice != currentCallType;

    deviceService.enableCamera(userService.localUserInfo.camera);
    deviceService.enableMic(userService.localUserInfo.mic);
    deviceService.enableSpeaker(true);
    deviceService.resetDeviceConfig();
  }

  @override
  void onCallingStateUpdated(ZegoCallingState state) {
    logInfo('state:${state.string}');

    pageHandler.onCallingStateUpdated(state);
  }

  @override
  void onReceiveCallAccepted(ZegoUserInfo callee) {
    logInfo('callee:${callee.toString()}');

    caller = ZegoServiceManager.shared.userService.localUserInfo;
    callee = callee;

    callTimeManager.startTimer(currentCallID());

    currentCallStatus = ZegoCallStatus.calling;

    pageHandler.onReceiveCallAccepted(callee);
  }

  @override
  void onReceiveCallCanceled(ZegoUserInfo caller) {
    logInfo('caller:${caller.toString()}');

    if ((currentCallStatus == ZegoCallStatus.calling ||
            currentCallStatus == ZegoCallStatus.wait) &&
        this.caller.userID != caller.userID) {
      logInfo(
          'call status is not right:$currentCallStatus, and user id is different:[${this.caller.userID}, ${caller.userID}]');
      return;
    }

    callTimeManager.stopTimer(currentCallID());
    ZegoNotificationRing.shared.stopRing();

    pageHandler.onReceiveCallCanceled(caller);

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();
  }

  @override
  void onReceiveCallDecline(ZegoUserInfo callee, ZegoDeclineType type) {
    logInfo('user:${callee.toString()}, type:${type.string}');

    callTimeManager.stopTimer(currentCallID());
    ZegoNotificationRing.shared.stopRing();

    pageHandler.onReceiveCallDecline(callee, type);

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();
  }

  @override
  void onReceiveCallEnded() {
    logInfo('receive');

    callTimeManager.stopTimer(currentCallID());
    ZegoNotificationRing.shared.stopRing();

    pageHandler.onReceiveCallEnded();

    currentCallStatus = ZegoCallStatus.free;
    resetCallUserInfo();
  }

  @override
  void onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type) {
    logInfo('caller:${caller.toString()}, '
        'type:${type.string}');

    if (currentCallStatus == ZegoCallStatus.calling ||
        currentCallStatus == ZegoCallStatus.wait ||
        currentCallStatus == ZegoCallStatus.waitAccept) {
      logInfo('call status is not right:$currentCallStatus');
      return;
    }

    callTimeManager.stopTimer(currentCallID());
    ZegoNotificationRing.shared.startRing();

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
    logInfo('request');

    pageHandler.onMiniOverlayRequest();
  }

  void onMiniOverlayRestore() {
    logInfo('restore');

    pageHandler.onMiniOverlayRestore();
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo caller, ZegoCallTimeoutType type) {
    logInfo('caller:${caller.toString()}, type:${type.string}');

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
    logInfo('audio route:$audioRoute');
  }

  @override
  void onNetworkQuality(String userID, ZegoStreamQualityLevel level) {
    var isStable = (level == ZegoStreamQualityLevel.Excellent ||
        level == ZegoStreamQualityLevel.Good ||
        level == ZegoStreamQualityLevel.Medium);
    if (isStable) {
      return;
    }

    logInfo("user id:$userID, level:$level");

    final ZegoNavigationService _navigationService =
        locator<ZegoNavigationService>();
    var context = _navigationService.navigatorKey.currentContext!;
    ZegoToastManager.shared.showToast(localUserInfo?.userID == userID
        ? AppLocalizations.of(context)!.networkConnnectMeUnstable
        : AppLocalizations.of(context)!.networkConnnectOtherUnstable);
  }

  @override
  void onUserInfoUpdate(ZegoUserInfo info) {
    logInfo('user:${info.toString()}');

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

  String currentCallID() {
    return ZegoServiceManager.shared.callService.callInfo.callID;
  }

  @override
  void onRoomInfoUpdate(ZegoRoomInfo info) {}

  @override
  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond) {
    delegate?.onRoomTokenWillExpire(roomID, remainTimeInSecond);
  }
}
