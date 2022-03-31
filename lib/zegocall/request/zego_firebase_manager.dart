// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:result_type/result_type.dart';

// Project imports:
import '../command/zego_request_protocol.dart';
import '../listener/zego_listener.dart';
import './../core/zego_call_defines.dart';
import './../listener/zego_listener_manager.dart';

class ZegoFireBaseManager extends ZegoRequestProtocol {
  static var shared = ZegoFireBaseManager();

  String fcmToken = "";
  User? user;

  StreamSubscription<DatabaseEvent>? connectedListenerSubscription;
  StreamSubscription<DatabaseEvent>? fcmTokenListenerSubscription;
  StreamSubscription<DatabaseEvent>? incomingCallListenerSubscription;
  StreamSubscription<DatabaseEvent>? callListenerSubscription;

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

  void init() {
    addConnectedListener();

    FirebaseAuth.instance.authStateChanges().listen((event) {
      user = event;
    });

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
    var userID = parameters['id'] as String;
    var effectiveTimeInSeconds = parameters['effective_time'] as int;

    RequestResult result = Success('');

    Map<String, dynamic> data = {
      'id': userID,
      'effective_time': effectiveTimeInSeconds
    };
    await FirebaseFunctions.instance.httpsCallable('getToken').call(data).then(
        (value) {
      var dict = value as Map<String, dynamic>;
      var token = dict['token'] as String;
      result = Success(token);
    }, onError: (error) {
      result = Failure(ZegoError.failed);
    });

    return result;
  }

  void addUserToDatabase(User user) {
    addUser(User user, String token) {
      var data = {
        "user_id": user.uid,
        "display_name": user.displayName,
        "token_id": token,
        "last_changed": DateTime.now().millisecondsSinceEpoch
      };
      var userRef =
          FirebaseDatabase.instance.ref('online_user').child(user.uid);
      userRef.set(data);
      userRef.onDisconnect().remove();

      var platform = "android";
      if (Platform.isIOS) {
        platform = "ios";
      }
      var fcmTokenRef = FirebaseDatabase.instance
          .ref('push_token')
          .child(user.uid)
          .child(token);
      var tokenData = {
        "device_type": platform,
        "token_id": fcmToken,
        "user_id": user.uid
      };
      fcmTokenRef.set(tokenData);
    }

    if (fcmToken.isEmpty) {
      FirebaseMessaging.instance.getToken().then((token) {
        fcmToken = token ?? "";
        addUser(user, fcmToken);
        addFcmTokenListener();
      });
    } else {
      addUser(user, fcmToken);
    }
  }

  void addConnectedListener() {
    final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
    connectedListenerSubscription = connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;
      if (!connected) {
        return;
      }
      if (user == null) {
        return;
      }
      addUserToDatabase(user!);
    });
  }

  void addFcmTokenListener() {
    fcmTokenListenerSubscription = FirebaseDatabase.instance
        .ref('online_user')
        .child(user!.uid)
        .child('token_id')
        .onValue
        .listen((DatabaseEvent event) async {
      var token = event.snapshot.value ?? "";
      if (token == fcmToken) {
        return;
      }

      await FirebaseAuth.instance.signOut();
      resetData(false);

      ZegoNotifyListenerParameter parameter = {};
      parameter["error"] = 1;
      ZegoListenerManager.shared.receiveUpdate(notifyUserError, parameter);
    });
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
    if (callListenerSubscription != null) {
      callListenerSubscription!.cancel();
    }

    if (user != null) {
      FirebaseDatabase.instance
          .ref('push_token')
          .child(user!.uid)
          .child(fcmToken)
          .remove();

      fcmToken = "";

      FirebaseDatabase.instance.ref('online_user').onDisconnect().cancel();

      if (removeUserData) {
        FirebaseDatabase.instance.ref('online_user').child(user!.uid).remove();
      }

      user = null;
    }
  }
}
