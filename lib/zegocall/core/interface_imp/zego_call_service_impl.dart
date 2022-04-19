// Dart imports:
import 'dart:async';

// Package imports:
import 'package:result_type/result_type.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../../../logger.dart';
import '../../listener/zego_listener.dart';
import '../../listener/zego_listener_manager.dart';
import '../commands/zego_accept_call_command.dart';
import '../commands/zego_call_command.dart';
import '../commands/zego_cancel_call_command.dart';
import '../commands/zego_decline_call_command.dart';
import '../commands/zego_end_call_command.dart';
import '../commands/zego_heartbeat_command.dart';
import '../interface/zego_call_service.dart';
import '../interface/zego_event_handler.dart';
import '../manager/zego_service_manager.dart';
import '../model/zego_call_info.dart';
import '../model/zego_user_info.dart';
import '../zego_call_defines.dart';

class ZegoCallServiceImpl extends IZegoCallService with ZegoEventHandler {
  bool isHeartbeatTimerRunning = false;
  Timer? callTimer;
  String currentRoomID = "";

  ZegoCallCommand? callUserCommand;
  CommandCallback? callUserCallback;
  ZegoAcceptCallCommand? acceptCallCommand;
  CommandCallback? acceptCallCallback;

  @override
  void init() {
    logInfo('init');

    registerListener();

    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  ZegoError callUser(ZegoUserInfo callee, String token, ZegoCallType type,
      CommandCallback callback) {
    if (!ZegoServiceManager.shared.isSDKInit) {
      assert(false, "The SDK must be initialised first.");
      return ZegoError.notInit;
    }

    if (ZegoServiceManager.shared.userService.localUserInfo.isEmpty()) {
      assert(false, "Must be logged in first.");
      return ZegoError.notLogin;
    }

    assert(callee.userID.length <= 64,
        "The User ID length must be less than or equal to 64.");

    if (token.isEmpty) {
      logInfo('token is empty');
      return ZegoError.failed;
    }
    if (status != LocalUserStatus.free) {
      logInfo('status is not free');
      return ZegoError.failed;
    }
    if (callee.userID.isEmpty) {
      logInfo('user id is empty');
      return ZegoError.failed;
    }

    var caller = ZegoServiceManager.shared.userService.localUserInfo;
    var callerID = caller.userID;
    var callID = generateCallID(callerID);

    logInfo(
        'callID:$callID, callerID:$callerID, calleeID:${callee.userID}, type:$type, status:$status');

    callInfo.callID = callID;
    callInfo.caller = caller;
    callInfo.callees = [callee];

    currentRoomID = callID;

    status = LocalUserStatus.outgoing;

    callUserCommand = ZegoCallCommand(callID, caller, [callee], type);
    callUserCallback = callback;

    addCallTimer();

    ZegoServiceManager.shared.roomService.joinRoom(callID, token);

    return ZegoError.success;
  }

  void callUserToServer() {
    callUserCommand?.execute().then((value) {
      handleCallUserResult(value);
    }, onError: (error) {
      handleCallUserResult(Failure(error));
    });
  }

  void handleCallUserResult(RequestResult result) {
    // if call user failed
    if (result.isFailure) {
      status = LocalUserStatus.free;
      cancelCallTimer();
    }

    var callback = callUserCallback;
    callUserCallback = null;
    if (null != callback) {
      callback(result.isSuccess ? ZegoError.success.id : result.failure.id);
    }
  }

  @override
  Future<ZegoError> cancelCall() async {
    if (!ZegoServiceManager.shared.isSDKInit) {
      assert(false, "The SDK must be initialised first.");
      return ZegoError.notInit;
    }

    if (ZegoServiceManager.shared.userService.localUserInfo.isEmpty()) {
      assert(false, "Must be logged in first.");
      return ZegoError.notLogin;
    }

    if (status != LocalUserStatus.outgoing) {
      logInfo('status is wrong, $status');
      return ZegoError.callStatusWrong;
    }

    if (callInfo.callees.isEmpty) {
      logInfo('callees is empty');
      return ZegoError.failed;
    }

    var calleeID = callInfo.callees.first.userID;
    var callID = callInfo.callID;
    var callerUserID =
        ZegoServiceManager.shared.userService.localUserInfo.userID;
    logInfo(
        'callID:$callID, calleeID:$calleeID, callerUserID:$callerUserID, status:$status');

    ZegoServiceManager.shared.roomService.leaveRoom();

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    cancelCallTimer();

    var command = ZegoCancelCallCommand(callerUserID, callID, calleeID);
    var result = await command.execute();
    return result.isSuccess ? ZegoError.success : result.failure;
  }

  @override
  ZegoError acceptCall(String token, CommandCallback callback) {
    if (!ZegoServiceManager.shared.isSDKInit) {
      assert(false, "The SDK must be initialised first.");
      return ZegoError.notInit;
    }

    if (ZegoServiceManager.shared.userService.localUserInfo.isEmpty()) {
      assert(false, "Must be logged in first.");
      return ZegoError.notLogin;
    }

    if (status != LocalUserStatus.incoming) {
      logInfo("[call service] accept call, status is wrong, $status");
      return ZegoError.callStatusWrong;
    }

    if (callInfo.callID.isEmpty) {
      logInfo('call id is empty');
      return ZegoError.failed;
    }

    var callerUserID =
        ZegoServiceManager.shared.userService.localUserInfo.userID;

    logInfo('callID:${callInfo.callID}, userID:$callerUserID, status:$status');

    status = LocalUserStatus.calling;
    currentRoomID = callInfo.callID;

    acceptCallCommand = ZegoAcceptCallCommand(callerUserID, callInfo.callID);
    acceptCallCallback = callback;

    ZegoServiceManager.shared.roomService.joinRoom(currentRoomID, token);

    return ZegoError.success;
  }

  void acceptCallToServer() {
    acceptCallCommand?.execute().then((value) {
      handleAcceptCallResult(value);
    }, onError: (error) {
      handleAcceptCallResult(Failure(error));
    });
  }

  void handleAcceptCallResult(RequestResult result) {
    // if accept call success
    if (result.isSuccess) {
      status = LocalUserStatus.calling;
      cancelCallTimer();
      startHeartbeatTimer();
    } else {
      ZegoServiceManager.shared.roomService.leaveRoom();
    }

    var callback = acceptCallCallback;
    acceptCallCallback = null;
    if (null != callback) {
      callback(result.isSuccess ? ZegoError.success.id : result.failure.id);
    }
  }

  @override
  Future<ZegoError> declineCall() async {
    if (!ZegoServiceManager.shared.isSDKInit) {
      assert(false, "The SDK must be initialised first.");
      return ZegoError.notInit;
    }

    if (ZegoServiceManager.shared.userService.localUserInfo.isEmpty()) {
      assert(false, "Must be logged in first.");
      return ZegoError.notLogin;
    }

    if (status != LocalUserStatus.incoming &&
        status != LocalUserStatus.calling) {
      logInfo('status is wrong, $status');
      return ZegoError.callStatusWrong;
    }

    logInfo('decline');

    status = LocalUserStatus.free;
    cancelCallTimer();

    ZegoServiceManager.shared.roomService.leaveRoom();

    var userID = ZegoServiceManager.shared.userService.localUserInfo.userID;
    return _declineCall(userID, callInfo.callID, callInfo.caller.userID,
        ZegoDeclineType.kZegoDeclineTypeDecline);
  }

  Future<ZegoError> _declineCall(String userID, String callID, String callerID,
      ZegoDeclineType type) async {
    logInfo(
        'userID:$userID, callID:$callID, callerID:$callerID, type:$type, status:$status');

    var command = ZegoDeclineCallCommand(userID, callID, callerID, type);

    var result = await command.execute();
    return result.isSuccess ? ZegoError.success : result.failure;
  }

  @override
  Future<ZegoError> endCall() async {
    if (!ZegoServiceManager.shared.isSDKInit) {
      assert(false, "The SDK must be initialised first.");
      return ZegoError.notInit;
    }

    if (ZegoServiceManager.shared.userService.localUserInfo.isEmpty()) {
      assert(false, "Must be logged in first.");
      return ZegoError.notLogin;
    }

    if (status != LocalUserStatus.calling) {
      logInfo('status is wrong, $status');
      return ZegoError.callStatusWrong;
    }

    ZegoServiceManager.shared.roomService.leaveRoom();

    status = LocalUserStatus.free;
    stopHeartbeatTimer();

    var callerUserID =
        ZegoServiceManager.shared.userService.localUserInfo.userID;
    var command = ZegoEndCallCommand(callerUserID, callInfo.callID);

    var result = await command.execute();
    return result.isSuccess ? ZegoError.success : result.failure;
  }

  @override
  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    logInfo(
        'roomID:$roomID, state:$state, errorCode:$errorCode, extendedData:$extendedData');

    if (currentRoomID != roomID) {
      logInfo('room id is not equal');
      return;
    }

    // if the callUserCallback is not nil, means `CallUser` method didn't finish
    if (null != callUserCallback) {
      if (state == ZegoRoomState.Connecting) {
        return;
      } else if (state == ZegoRoomState.Disconnected) {
        var result = ZegoError.failed;
        if (1002033 == errorCode) {
          result = ZegoError.tokenExpired;
        }
        handleCallUserResult(Failure(result));
      } else {
        callUserToServer();
      }

      return;
    }

    // if the acceptCallBack is not nil, means `acceptCall` didn't finish
    if (null != acceptCallCallback) {
      if (state == ZegoRoomState.Connecting) {
        return;
      } else if (state == ZegoRoomState.Disconnected) {
        var result = ZegoError.failed;
        if (1002033 == errorCode) {
          result = ZegoError.tokenExpired;
        }
        handleAcceptCallResult(Failure(result));
      } else {
        acceptCallToServer();
      }

      return;
    }

    // if myself disconnected, just callback the `timeout`.
    if (ZegoRoomState.Disconnected == state &&
        status == LocalUserStatus.calling) {
      status = LocalUserStatus.free;
      callInfo = ZegoCallInfo.empty();

      ZegoServiceManager.shared.roomService.leaveRoom();

      delegate?.onReceiveCallTimeout(
          ZegoServiceManager.shared.userService.localUserInfo,
          ZegoCallTimeoutType.calling);

      stopHeartbeatTimer();
    } else {
      var callingState = ZegoCallingState.connected;
      switch (state) {
        case ZegoRoomState.Disconnected:
          callingState = ZegoCallingState.disconnected;
          break;
        case ZegoRoomState.Connecting:
          callingState = ZegoCallingState.connecting;
          break;
        case ZegoRoomState.Connected:
          callingState = ZegoCallingState.connected;
          break;
      }
      delegate?.onCallingStateUpdated(callingState);
    }
  }

  String generateCallID(String userID) {
    return userID + "${DateTime.now().millisecondsSinceEpoch}";
  }

  ZegoUserInfo getUser(String userID) {
    if (callInfo.caller.userID == userID) {
      return callInfo.caller;
    }
    return callInfo.callees.firstWhere((user) => user.userID == userID,
        orElse: () => ZegoUserInfo.empty());
  }

  void startHeartbeatTimer() {
    logInfo('start');

    isHeartbeatTimerRunning = true;

    Timer.periodic(const Duration(seconds: 20), (Timer timer) {
      if (!isHeartbeatTimerRunning) {
        logInfo('heart beat timer is not running, cancel it.');

        timer.cancel();
        return;
      }

      logInfo('heart beat...');

      var command = ZegoHeartbeatCommand(
          ZegoServiceManager.shared.userService.localUserInfo.userID,
          callInfo.callID);
      command.execute();
    });
  }

  void stopHeartbeatTimer() {
    logInfo('stop');
    isHeartbeatTimerRunning = false;
  }

  void addCallTimer() {
    callTimer = Timer(const Duration(seconds: 60), () {
      status = LocalUserStatus.free;
      callInfo = ZegoCallInfo.empty();

      ZegoServiceManager.shared.roomService.leaveRoom();

      delegate?.onReceiveCallTimeout(
          ZegoServiceManager.shared.userService.localUserInfo,
          ZegoCallTimeoutType.connecting);
    });
  }

  void cancelCallTimer() {
    callTimer?.cancel();
  }

  void registerListener() {
    ZegoListenerManager.shared
        .addListener(notifyCallInvited, onCallInvitedNotify);
    ZegoListenerManager.shared
        .addListener(notifyCallCanceled, onCallCanceledNotify);
    ZegoListenerManager.shared
        .addListener(notifyCallAccept, onCallAcceptNotify);
    ZegoListenerManager.shared
        .addListener(notifyCallDecline, onCallDeclineNotify);
    ZegoListenerManager.shared.addListener(notifyCallEnd, onCallEndNotify);
    ZegoListenerManager.shared
        .addListener(notifyCallTimeout, onCallTimeoutNotify);
  }

  void onCallInvitedNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var callType =
        ZegoCallTypeExtension.mapValue[parameter['call_type'] as int]!;
    var caller = parameter['caller'] as ZegoUserInfo;
    var callees = parameter['callees'] as List<ZegoUserInfo>;

    logInfo('callID:$callID, callerID:${caller.userID}, '
        'type:${callType.string}, status:$status');

    if (status != LocalUserStatus.free) {
      logInfo('status is not free');

      _declineCall(ZegoServiceManager.shared.userService.localUserInfo.userID,
          callID, caller.userID, ZegoDeclineType.kZegoDeclineTypeBusy);
      return;
    }

    status = LocalUserStatus.incoming;
    callInfo.callID = callID;
    addCallTimer();

    callInfo.caller = caller;
    callInfo.callees = callees;

    delegate?.onReceiveCallInvite(caller, callType);
  }

  void onCallCanceledNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var callerID = parameter['caller_id'] as String;
    logInfo('callID:$callID, callerID:$callerID, status:$status');

    if (callInfo.callID != callID) {
      logInfo(
          'call id is different, call info callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.incoming) {
      logInfo('status is not incoming');
      return;
    }
    if (callInfo.caller.userID != callerID) {
      logInfo('caller id is different, call info '
          'caller userID:${callInfo.caller.userID}, parameter '
          'callerID:$callerID');
      return;
    }

    var caller = callInfo.caller;

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    cancelCallTimer();

    delegate?.onReceiveCallCanceled(caller);
  }

  void onCallAcceptNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var calleeID = parameter['callee_id'] as String;

    logInfo('callID:$callID, calleeID:$calleeID, status:$status');

    if (callInfo.callID != callID) {
      logInfo(
          'call id is different, call info callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.outgoing) {
      logInfo('status is not outgoing');
      return;
    }

    var callee = callInfo.callees.firstWhere((user) => user.userID == calleeID,
        orElse: () => ZegoUserInfo.empty());

    cancelCallTimer();
    startHeartbeatTimer();

    status = LocalUserStatus.calling;

    delegate?.onReceiveCallAccepted(callee);
  }

  void onCallDeclineNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var calleeID = parameter['callee_id'] as String;
    var declineType =
        ZegoDeclineTypeExtension.mapValue[parameter['type'] as int]!;

    logInfo('callID:$callID, calleeID:$calleeID, '
        'type:${declineType.string}, status:$status');

    if (callInfo.callID != callID) {
      logInfo('call id is different, call info '
          'callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.outgoing) {
      logInfo('status is not outgoing');
      return;
    }

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    cancelCallTimer();

    ZegoServiceManager.shared.roomService.leaveRoom();

    var callee = callInfo.callees.firstWhere((user) => user.userID == calleeID,
        orElse: () => ZegoUserInfo.empty());
    delegate?.onReceiveCallDecline(callee, declineType);
  }

  void onCallEndNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var userID = parameter['user_id'] as String;

    logInfo('callID:$callID, userID:$userID, status:$status');

    if (callInfo.callID != callID) {
      logInfo('call id is different, call info '
          'callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.calling) {
      logInfo('status is not calling');
      return;
    }
    if (userID == ZegoServiceManager.shared.userService.localUserInfo.userID) {
      logInfo('can\'t receive myself ended call');
      return;
    }
    if (callInfo.caller.userID != userID &&
        callInfo.callees
            .firstWhere((user) => user.userID == userID,
                orElse: () => ZegoUserInfo.empty())
            .isEmpty()) {
      logInfo('the user ended call is not caller or callees');
      return;
    }
    stopHeartbeatTimer();

    ZegoServiceManager.shared.roomService.leaveRoom();

    delegate?.onReceiveCallEnded();

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
  }

  void onCallTimeoutNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var callerID = parameter['user_id'] as String;

    logInfo('callID:$callID, caller ID:$callerID, status:$status');

    if (callInfo.callID != callID) {
      logInfo('call id is different, call info '
          'callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.calling) {
      logInfo('status is not calling');
      return;
    }
    var caller = getUser(callerID);
    if (caller.isEmpty()) {
      logInfo('user is empty');
      return;
    }

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    stopHeartbeatTimer();

    ZegoServiceManager.shared.roomService.leaveRoom();

    delegate?.onReceiveCallTimeout(caller, ZegoCallTimeoutType.calling);
  }
}
