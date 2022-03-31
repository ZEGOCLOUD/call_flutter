// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:result_type/result_type.dart';

// Project imports:
import './../core/zego_call_defines.dart';
import './../listener/zego_listener_manager.dart';
import '../command/zego_request_protocol.dart';
import '../listener/zego_listener.dart';

class ZegoFireBaseManager extends ZegoRequestProtocol {
  static var shared = ZegoFireBaseManager();

  Map<String, Function(RequestParameterType)> functionMap = {};

  @override
  Future<RequestResult> request(
      String path, RequestParameterType parameters) async {
    print('[FireBase call] path:$path, parameters:$parameters');

    if (!functionMap.containsKey(path)) {
      return Failure(ZegoError.firebasePathNotExist);
    }

    return functionMap[path]!(parameters);
  }

  void initFunctionMap() {
    functionMap[apiStartCall] = callUsers;
    functionMap[apiCancelCall] = cancelCall;
    functionMap[apiAcceptCall] = acceptCall;
    functionMap[apiDeclineCall] = declineCall;
    functionMap[apiEndCall] = endCall;
    functionMap[apiCallHeartbeat] = heartbeat;
    functionMap[apiGetToken] = getToken;
  }



  Future<RequestResult> callUsers(RequestParameterType parameters) async {
    return Success("");
  }

  Future<RequestResult> cancelCall(RequestParameterType parameters) async {
    return Success("");
  }

  Future<RequestResult> acceptCall(RequestParameterType parameters) async {
    return Success("");
  }

  Future<RequestResult> declineCall(RequestParameterType parameters) async {
    return Success("");
  }

  Future<RequestResult> endCall(RequestParameterType parameters) async {
    return Success("");
  }

  Future<RequestResult> heartbeat(RequestParameterType parameters) async {
    return Success("");
  }

  Future<RequestResult> getToken(RequestParameterType parameters) async {
    return Success("");
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

  void resetData(bool removeUserData) {
    //todo
  }
}
