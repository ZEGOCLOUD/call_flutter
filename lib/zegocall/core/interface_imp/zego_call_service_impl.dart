// Dart imports:
import 'dart:async';
import 'dart:developer';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../../../zegocall/core/commands/zego_accept_call_command.dart';
import '../../../zegocall/core/commands/zego_call_command.dart';
import '../../../zegocall/core/commands/zego_cancel_call_command.dart';
import '../../../zegocall/core/commands/zego_decline_call_command.dart';
import '../../../zegocall/core/commands/zego_end_call_command.dart';
import '../../../zegocall/core/commands/zego_heartbeat_command.dart';
import '../../../zegocall/core/model/zego_call_info.dart';
import '../../../zegocall/listener/zego_listener_manager.dart';
import '../../listener/zego_listener.dart';
import '../interface/zego_call_service.dart';
import '../interface/zego_event_handler.dart';
import './../manager/zego_service_manager.dart';
import './../model/zego_user_info.dart';
import './../zego_call_defines.dart';

class ZegoCallServiceImpl extends IZegoCallService with ZegoEventHandler {
  bool isHeartbeatTimerRunning = false;
  bool isCallTimerRunning = false;
  String currentRoomID = "";
  String currentToken = "";

  @override
  void init() {
    registerListener();

    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  Future<int> callUser(
      ZegoUserInfo callee, String token, ZegoCallType type) async {
    if (callee.userID.isEmpty) {
      log('[call service] call user, user id is empty');
      return -1;
    }

    var caller = ZegoServiceManager.shared.userService.localUserInfo;
    var callerID = caller.userID;
    var callID = generateCallID(callerID);

    log('[call service] call user, callID:$callID, callerID:$callerID, '
        'calleeID:${callee.userID}, type:$type, status:$status');

    status = LocalUserStatus.outgoing;

    var command = ZegoCallCommand(callID, caller, [callee], type);
    callInfo.callID = callID;
    callInfo.caller = caller;
    callInfo.callees = [callee];

    var result = await command.execute();
    if (result.isSuccess) {
      // ZegoServiceManager.shared.roomService.joinRoom(callID, token);
      startCallTimer();
    } else {
      status = LocalUserStatus.free;
      return result.failure.id;
    }

    return 0;
  }

  @override
  Future<int> cancelCall() async {
    if (callInfo.callees.isEmpty) {
      log('[call service] cancel call, callees is empty');
      return -1;
    }

    var calleeID = callInfo.callees.first.userID;
    log('[call service] cancel call, callID:${callInfo.callID}, '
        'calleeID:$calleeID, status:$status');

    ZegoServiceManager.shared.roomService.leaveRoom();

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    cancelCallTimer();

    var callerUserID =
        ZegoServiceManager.shared.userService.localUserInfo.userID;
    var command =
        ZegoCancelCallCommand(callerUserID, callInfo.callID, calleeID);
    var result = await command.execute();
    if (result.isSuccess) {
    } else {
      return result.failure.id;
    }
    return 0;
  }

  @override
  Future<int> acceptCall(String token) async {
    var callerUserID =
        ZegoServiceManager.shared.userService.localUserInfo.userID;

    log('[call service] accept call, callID:${callInfo.callID}, '
        'userID:$callerUserID, status:$status');

    currentToken = token;

    var command = ZegoAcceptCallCommand(callerUserID, callInfo.callID);
    var result = await command.execute();
    if (result.isSuccess) {
      status = LocalUserStatus.calling;
      var roomID = callInfo.callID;

      ZegoServiceManager.shared.roomService.joinRoom(roomID, token);

      cancelCallTimer();
      startHeartbeatTimer();
    } else {
      return result.failure.id;
    }
    return 0;
  }

  @override
  Future<int> declineCall() async {
    log("[call service] decline call");

    status = LocalUserStatus.free;
    cancelCallTimer();

    var userID = ZegoServiceManager.shared.userService.localUserInfo.userID;
    return _declineCall(userID, callInfo.callID, callInfo.caller.userID,
        ZegoDeclineType.kZegoDeclineTypeDecline);
  }

  Future<int> _declineCall(String userID, String callID, String callerID,
      ZegoDeclineType type) async {
    log("[call service] decline call, userID:$userID, callID:$callID, "
        "callerID:$callerID, type:$type, status:$status");

    var command = ZegoDeclineCallCommand(userID, callID, callerID, type);

    var result = await command.execute();
    if (result.isSuccess) {
    } else {
      return result.failure.id;
    }

    return 0;
  }

  @override
  Future<int> endCall() async {
    ZegoServiceManager.shared.roomService.leaveRoom();

    status = LocalUserStatus.free;
    stopHeartbeatTimer();

    var callerUserID =
        ZegoServiceManager.shared.userService.localUserInfo.userID;
    var command = ZegoEndCallCommand(callerUserID, callInfo.callID);

    var result = await command.execute();
    if (result.isSuccess) {
    } else {
      return result.failure.id;
    }

    return 0;
  }

  @override
  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    if (ZegoRoomState.Disconnected == state &&
        status == LocalUserStatus.calling) {
      status = LocalUserStatus.free;
      callInfo = ZegoCallInfo.empty();

      ZegoServiceManager.shared.roomService.leaveRoom();

      delegate?.onReceiveCallTimeout(
          ZegoServiceManager.shared.userService.localUserInfo,
          ZegoCallTimeoutType.calling);
      stopHeartbeatTimer();
    }

    if (currentRoomID == roomID) {
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
    currentRoomID = roomID;
  }

  String generateCallID(String userID) {
    return userID + "${DateTime.now().millisecondsSinceEpoch * 1000}";
  }

  ZegoUserInfo getUser(String userID) {
    if (callInfo.caller.userID == userID) {
      return callInfo.caller;
    }
    return callInfo.callees.firstWhere((user) => user.userID == userID,
        orElse: () => ZegoUserInfo.empty());
  }

  void startHeartbeatTimer() {
    isHeartbeatTimerRunning = true;

    Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (!isHeartbeatTimerRunning) {
        timer.cancel();
        return;
      }

      var command = ZegoHeartbeatCommand(
          ZegoServiceManager.shared.userService.localUserInfo.userID,
          callInfo.callID);
      command.execute();
    });
  }

  void stopHeartbeatTimer() {
    isHeartbeatTimerRunning = false;
  }

  void startCallTimer() {
    isCallTimerRunning = true;

    Timer(const Duration(seconds: 60), () {
      if (!isCallTimerRunning) {
        return;
      }

      delegate?.onReceiveCallTimeout(
          ZegoServiceManager.shared.userService.localUserInfo,
          ZegoCallTimeoutType.connecting);
    });
  }

  void cancelCallTimer() {
    isCallTimerRunning = false;
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
    ZegoListenerManager.shared.addListener(notifyUserError, onUserErrorNotify);
  }

  void onCallInvitedNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var callType =
        ZegoCallTypeExtension.mapValue[parameter['call_type'] as int]!;
    var caller = parameter['caller'] as ZegoUserInfo;
    var callees = parameter['callees'] as List<ZegoUserInfo>;

    log('[call service] invited notify, callID:$callID, callerID:${caller.userID}, '
        'type:${callType.string}, status:$status');

    if (status != LocalUserStatus.free) {
      log('[call service] invited notify, status is not free');

      declineCall();
      return;
    }

    status = LocalUserStatus.incoming;
    callInfo.callID = callID;
    startCallTimer();

    callInfo.caller = caller;
    callInfo.callees = callees;

    delegate?.onReceiveCallInvite(caller, callType);
  }

  void onCallCanceledNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var callerID = parameter['caller_id'] as String;
    log('[call service] canceled notify, callID:$callID, callerID:$callerID, '
        'status:$status');

    if (callInfo.callID != callID) {
      log('[call service] canceled notify, call id is different, call info '
          'callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.incoming) {
      log('[call service] canceled notify, status is not incoming');
      return;
    }
    if (callInfo.caller.userID != callerID) {
      log('[call service] canceled notify, caller id is different, call info '
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

    log('[call service] accept notify, callID:$callID, calleeID:$calleeID, '
        'status:$status');

    if (callInfo.callID != callID) {
      log('[call service] accept notify, call id is different, call info '
          'callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.outgoing) {
      log('[call service] accept notify, status is not outgoing');
      return;
    }

    var callee = callInfo.callees.firstWhere((user) => user.userID == calleeID,
        orElse: () => ZegoUserInfo.empty());

    cancelCallTimer();
    startHeartbeatTimer();

    if (currentToken.isNotEmpty) {
      ZegoServiceManager.shared.roomService.joinRoom(callID, currentToken);
    }

    status = LocalUserStatus.calling;

    delegate?.onReceiveCallAccept(callee);
  }

  void onCallDeclineNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var calleeID = parameter['callee_id'] as String;
    var declineType = ZegoDeclineType.values[parameter['type'] as int];

    log('[call service] decline notify, callID:$callID, calleeID:$calleeID, '
        'type:${declineType.string}, status:$status');

    if (callInfo.callID != callID) {
      log('[call service] decline notify, call id is different, call info '
          'callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.outgoing) {
      log('[call service] decline notify, status is not outgoing');
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

    log('[call service] end notify, callID:$callID, userID:$userID, status:$status');

    if (callInfo.callID != callID) {
      log('[call service] end notify, call id is different, call info '
          'callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.calling) {
      log('[call service] end notify, status is not calling');
      return;
    }
    if (userID == ZegoServiceManager.shared.userService.localUserInfo.userID) {
      log('[call service] end notify, can\'t receive myself ended call');
      return;
    }
    if (callInfo.caller.userID != userID &&
        callInfo.callees
            .firstWhere((user) => user.userID == userID,
                orElse: () => ZegoUserInfo.empty())
            .isEmpty()) {
      log('[call service] end notify, the user ended call is not caller or callees');
      return;
    }

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    stopHeartbeatTimer();

    ZegoServiceManager.shared.roomService.leaveRoom();

    delegate?.onReceiveCallEnded();
  }

  void onCallTimeoutNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var userID = parameter['user_id'] as String;

    log('[call service] timeout notify, callID:$callID, userID:$userID, status:$status');

    if (callInfo.callID != callID) {
      log('[call service] timeout notify, call id is different, call info '
          'callID:${callInfo.callID}, parameter callID:$callID');
      return;
    }
    if (status != LocalUserStatus.calling) {
      log('[call service] timeout notify, status is not calling');
      return;
    }
    var user = getUser(userID);
    if (user.isEmpty()) {
      log('[call service] timeout notify, user is empty');
      return;
    }

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    stopHeartbeatTimer();

    ZegoServiceManager.shared.roomService.leaveRoom();

    delegate?.onReceiveCallTimeout(user, ZegoCallTimeoutType.calling);
  }

  void onUserErrorNotify(ZegoNotifyListenerParameter parameter) {
    var error = ZegoUserErrorExtension.mapValue[parameter['error'] as int]!;

    log('[call service] timeout notify, error:${error.string}, status:$status');

    if (ZegoUserError.kickOut == error) {
      status = LocalUserStatus.free;
      callInfo = ZegoCallInfo.empty();
      cancelCallTimer();
      stopHeartbeatTimer();

      ZegoServiceManager.shared.roomService.leaveRoom();
    }
  }
}
