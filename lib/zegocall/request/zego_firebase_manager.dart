// Project imports:
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import 'package:zego_call_flutter/zegocall/listener/zego_listener_manager.dart';
import '../command/zego_request_protocol.dart';
import '../listener/zego_listener.dart';

class ZegoFireBaseManager extends ZegoRequestProtocol {
  static var shared = ZegoFireBaseManager();

  Map<String, Function(Map<String, dynamic>)> functionMap = {};

  @override
  Future<ZegoError> request(
      String path, Map<String, dynamic> parameters) async {
    print('[FireBase call] path:$path, parameters:$parameters');

    if (!functionMap.containsKey(path)) {
      return ZegoError.firebasePathNotExist;
    }

    return functionMap[path]!(parameters);
  }

  void initFunctionMap() {
    functionMap[apiLogin] = login;
    functionMap[apiLogout] = logout;
    functionMap[apiGetUser] = getUser;
    functionMap[apiGetUsers] = getUserList;
    functionMap[apiStartCall] = callUsers;
    functionMap[apiCancelCall] = cancelCall;
    functionMap[apiAcceptCall] = acceptCall;
    functionMap[apiDeclineCall] = declineCall;
    functionMap[apiEndCall] = endCall;
    functionMap[apiCallHeartbeat] = heartbeat;
    functionMap[apiGetToken] = getToken;
  }

  Future<ZegoError> login(Map<String, dynamic> parameters) async {
    String token = parameters['token'] as String;
    return ZegoError.success;
  }

  Future<ZegoError> logout(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> getUser(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> getUserList(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> callUsers(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> cancelCall(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> acceptCall(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> declineCall(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> endCall(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> heartbeat(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  Future<ZegoError> getToken(Map<String, dynamic> parameters) async {
    return ZegoError.success;
  }

  void addUserToDatabase() {
    //
  }

  void addConnectedListener() {
    //
  }

  void addFcmTokenListener() {
    ZegoNotifyListenerParameter parameter = {};
    ZegoListenerManager.shared.receiveUpdate(notifyUserError, parameter);
  }

  void addOnlineUsersListener() {
    //
  }

  void addIncomingCallListener() {
    ZegoNotifyListenerParameter parameter = {};
    ZegoListenerManager.shared.receiveUpdate(notifyCallInvited, parameter);
  }

  void addCallListener() {
    ZegoNotifyListenerParameter parameter = {};
    ZegoListenerManager.shared.receiveUpdate(notifyCallCanceled, parameter);
    ZegoListenerManager.shared.receiveUpdate(notifyCallAccept, parameter);
    ZegoListenerManager.shared.receiveUpdate(notifyCallDecline, parameter);
    ZegoListenerManager.shared.receiveUpdate(notifyCallEnd, parameter);
  }
}
