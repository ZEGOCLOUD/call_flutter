// Dart imports:
import 'dart:async';
import 'dart:developer';

// Package imports:
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/commands/zego_accept_call_command.dart';
import 'package:zego_call_flutter/zegocall/core/commands/zego_call_command.dart';
import 'package:zego_call_flutter/zegocall/core/commands/zego_cancel_call_command.dart';
import 'package:zego_call_flutter/zegocall/core/commands/zego_decline_call_command.dart';
import 'package:zego_call_flutter/zegocall/core/commands/zego_end_call_command.dart';
import 'package:zego_call_flutter/zegocall/core/commands/zego_heartbeat_command.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_call_info.dart';
import 'package:zego_call_flutter/zegocall/listener/zego_listener_manager.dart';
import '../../listener/zego_listener.dart';
import '../interface/zego_call_service.dart';
import '../interface/zego_event_handler.dart';
import './../manager/zego_service_manager.dart';
import './../model/zego_user_info.dart';
import './../zego_call_defines.dart';

class ZegoCallServiceImpl extends IZegoCallService with ZegoEventHandler {
  bool isHeartbeatTimerRunning = false;
  bool isCallTimerRunning = false;

  @override
  void init() {
    registerListener();

    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  Future<int> callUser(
      ZegoUserInfo user, String token, ZegoCallType type) async {
    if (user.userID.isEmpty) {
      return -1;
    }

    status = LocalUserStatus.outgoing;

    var callerUserID =
        ZegoServiceManager.shared.userService.localUserInfo.userID;
    var callID = generateCallID(callerUserID);

    var command = ZegoCallCommand(
      callID,
      ZegoServiceManager.shared.userService.localUserInfo,
      [user],
      type,
    );

    var result = await command.execute();
    if (result.isSuccess) {
      ZegoServiceManager.shared.roomService.joinRoom(callID, token);
      startCallTimer();
    } else {
      status = LocalUserStatus.free;
      return result.failure.id;
    }

    return 0;
  }

  @override
  Future<int> cancelCall() async {
    ZegoServiceManager.shared.roomService.leaveRoom();

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    cancelCallTimer();

    var callerUserID =
        ZegoServiceManager.shared.userService.localUserInfo.userID;
    var command = ZegoCancelCallCommand(callerUserID, callInfo.callID);
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
    var command =
        ZegoDeclineCallCommand(callInfo.callID, callInfo.caller.userID);

    status = LocalUserStatus.free;
    cancelCallTimer();

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
      Map<String, dynamic> extendedData) {}

  String generateCallID(String userID) {
    return userID + "${DateTime.now().millisecondsSinceEpoch * 1000}";
  }

  ZegoUserInfo getUser(String userID) {
    if (callInfo.caller.userID == userID) {
      return callInfo.caller;
    }
    return callInfo.callees.firstWhere((user) => user.userID == userID);
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
    var callerID = parameter['caller_id'] as String;
    var callerName = parameter['caller_name'] as String;
    var callType = ZegoCallType.values[parameter['call_type'] as int];
    var callees = parameter['callees'] as List<ZegoUserInfo>;

    if (status != LocalUserStatus.free) {
      return;
    }

    status = LocalUserStatus.incoming;
    callInfo.callID = callID;
    startCallTimer();

    var caller = ZegoUserInfo(callerID, callerName);
    callInfo.caller = caller;
    callInfo.callees = callees;

    delegate?.onReceiveCallInvite(caller, callType);
  }

  void onCallCanceledNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var callerID = parameter['caller_id'] as String;

    if (callInfo.callID != callID) {
      return;
    }
    if (status != LocalUserStatus.incoming) {
      return;
    }
    if (callInfo.caller.userID != callerID) {
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

    if (callInfo.callID != callID) {
      return;
    }
    if (status != LocalUserStatus.outgoing) {
      return;
    }

    var callee = callInfo.callees.firstWhere((user) => user.userID == calleeID);

    cancelCallTimer();
    startHeartbeatTimer();
    status = LocalUserStatus.calling;

    delegate?.onReceiveCallAccept(callee);
  }

  void onCallDeclineNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var calleeID = parameter['callee_id'] as String;
    var declineType = ZegoDeclineType.values[parameter['type'] as int];

    if (callInfo.callID != callID) {
      return;
    }
    if (status != LocalUserStatus.outgoing) {
      return;
    }
    var callee = callInfo.callees.firstWhere((user) => user.userID == calleeID);

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    cancelCallTimer();

    ZegoServiceManager.shared.roomService.leaveRoom();

    delegate?.onReceiveCallDecline(callee, declineType);
  }

  void onCallEndNotify(ZegoNotifyListenerParameter parameter) {
    var callID = parameter['call_id'] as String;
    var userID = parameter['user_id'] as String;

    if (callInfo.callID != callID) {
      return;
    }
    if (status != LocalUserStatus.calling) {
      return;
    }
    if (userID == ZegoServiceManager.shared.userService.localUserInfo.userID) {
      // can't receive myself ended call
      return;
    }
    if (callInfo.caller.userID != userID &&
        callInfo.callees
            .firstWhere((user) => user.userID == userID)
            .isEmpty()) {
      // the user ended call is not caller or callees
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

    if (callInfo.callID != callID) {
      return;
    }
    if (status != LocalUserStatus.calling) {
      return;
    }
    var user = getUser(userID);
    if (user.isEmpty()) {
      return;
    }

    status = LocalUserStatus.free;
    callInfo = ZegoCallInfo.empty();
    // cancelCallTimer();
    stopHeartbeatTimer();

    ZegoServiceManager.shared.roomService.leaveRoom();

    delegate?.onReceiveCallTimeout(user, ZegoCallTimeoutType.calling);
  }

  void onUserErrorNotify(ZegoNotifyListenerParameter parameter) {
    var error = ZegoUserError.values[parameter['error'] as int];

    if (ZegoUserError.kickOut == error) {
      status = LocalUserStatus.free;
      callInfo = ZegoCallInfo.empty();
      cancelCallTimer();
      stopHeartbeatTimer();

      ZegoServiceManager.shared.roomService.leaveRoom();
    }
  }
}
