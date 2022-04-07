// Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:io';

// Package imports:
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:result_type/result_type.dart';

// Project imports:
import '../command/zego_request_protocol.dart';
import '../core/model/zego_user_info.dart';
import '../listener/zego_listener.dart';
import './../core/zego_call_defines.dart';
import './../listener/zego_listener_manager.dart';
import 'zego_firebase_call_model.dart';

class ZegoFireBaseManager extends ZegoRequestProtocol {
  static var shared = ZegoFireBaseManager();

  String fcmToken = "";
  ZegoFirebaseCallModel callModel = ZegoFirebaseCallModel.empty();
  User? user;

  StreamSubscription<DatabaseEvent>? connectedListenerSubscription;
  StreamSubscription<DatabaseEvent>? fcmTokenListenerSubscription;
  StreamSubscription<DatabaseEvent>? incomingCallListenerSubscription;
  StreamSubscription<DatabaseEvent>? callListenerSubscription;

  Map<String, Function(RequestParameterType)> functionMap = {};

  @override
  Future<RequestResult> request(
      String path, RequestParameterType parameters) async {
    log('[FireBase call] path:$path, parameters:$parameters');

    if (!functionMap.containsKey(path)) {
      return Failure(ZegoError.firebasePathNotExist);
    }

    return functionMap[path]!(parameters);
  }

  void init() {
    user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      user = user;

      if(null != user) {
        addFcmTokenToDatabase(user!);
        addIncomingCallListener();
      } else {
        resetData();
      }
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
    final callID = parameters["call_id"] as String;
    final caller = parameters["caller"] as ZegoUserInfo;
    final callees = parameters["callees"] as List<ZegoUserInfo>;
    final callType = FirebaseCallType.values[parameters["type"] as int];

    callModel = ZegoFirebaseCallModel.empty();
    callModel.callID = callID;
    callModel.callType = callType;
    callModel.callStatus = FirebaseCallStatus.connecting;
    callModel.users.clear();

    var firebaseCaller = FirebaseCallUser.empty();
    firebaseCaller.callerID = caller.userID;
    firebaseCaller.userID = caller.userID;
    firebaseCaller.userName = caller.userName;
    firebaseCaller.startTime = DateTime.now().millisecondsSinceEpoch;
    firebaseCaller.status = FirebaseCallStatus.connecting;
    callModel.users.add(firebaseCaller);

    for (var user in callees) {
      var callee = firebaseCaller;
      callee.userID = user.userID;
      callee.userName = user.userName;
      callModel.users.add(callee);
    }

    await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .set(callModel.toMap());

    addCallListener(callID);
    return Success("");
  }

  Future<RequestResult> cancelCall(RequestParameterType parameters) async {
    final calleeID = parameters["callee_id"] as String;
    final callID = parameters["call_id"] as String;

    var model = callModel;
    model.callStatus = FirebaseCallStatus.ended;

    model.getUser(user?.uid ?? "").status = FirebaseCallStatus.ended;
    model.getUser(calleeID).status = FirebaseCallStatus.ended;

    await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .update(model.toMap());

    return Success("");
  }

  Future<RequestResult> acceptCall(RequestParameterType parameters) async {
    final callID = parameters["call_id"] as String;

    var model = callModel;
    model.callStatus = FirebaseCallStatus.calling;
    for (var user in model.users) {
      user.status = FirebaseCallStatus.calling;
      user.connectedTime = DateTime.now().millisecondsSinceEpoch;
    }

    await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .update(model.toMap());

    return Success("");
  }

  Future<RequestResult> declineCall(RequestParameterType parameters) async {
    final callID = parameters["call_id"] as String;
    final type = ZegoDeclineType.values[parameters["type"] as int];

    var model = callModel;
    model.callStatus = FirebaseCallStatus.ended;
    for (var user in model.users) {
      user.status = (type == ZegoDeclineType.kZegoDeclineTypeDecline)
          ? FirebaseCallStatus.declined
          : FirebaseCallStatus.busy;
      user.connectedTime = DateTime.now().millisecondsSinceEpoch;
    }

    await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .update(model.toMap());

    return Success("");
  }

  Future<RequestResult> endCall(RequestParameterType parameters) async {
    final callID = parameters["call_id"] as String;

    var model = callModel;
    model.callStatus = FirebaseCallStatus.ended;
    for (var user in model.users) {
      user.status = FirebaseCallStatus.ended;
      user.finishTime = DateTime.now().millisecondsSinceEpoch;
    }

    await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .update(model.toMap());

    return Success("");
  }

  Future<RequestResult> heartbeat(RequestParameterType parameters) async {
    final userID = parameters["id"] as String;
    final callID = parameters["call_id"] as String;

    if (callModel.callStatus != FirebaseCallStatus.calling ||
        callModel.callID != callID) {
      return Success("");
    }
    var user = callModel.getUser(userID);
    user.heartbeatTime = DateTime.now().millisecondsSinceEpoch;

    await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .child('users')
        .child(userID)
        .update({'heartbeat_time': user.heartbeatTime});

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

  void addFcmTokenToDatabase(User user) {
    addFcmToken(User user, String token) {
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
        addFcmToken(user, fcmToken);
      });
    } else {
      addFcmToken(user, fcmToken);
    }
  }

  void addIncomingCallListener() {
    fcmTokenListenerSubscription = FirebaseDatabase.instance
        .ref('call')
        .onChildAdded
        .listen((DatabaseEvent event) async {
      var snapshotValue = event.snapshot.value;

      var dict = snapshotValue as Map<dynamic, dynamic>;
      log('[firebase] call onChildAdded: $dict');
      if(! dict.containsKey('call_status')) {
        return;
      }

      var callStatus = FirebaseCallStatusExtension
          .mapValue[dict['call_status'] as int] as FirebaseCallStatus;
      if (callStatus != FirebaseCallStatus.connecting) {
        return;
      }

      var model = ZegoFirebaseCallModel.fromMap(dict);
      var firebaseUser = model.getUser(user?.uid ?? "");
      if (firebaseUser.userID != firebaseUser.callerID) {
        return;
      }
      var caller = model.users.firstWhere(
          (user) => user.callerID == user.userID,
          orElse: () => FirebaseCallUser.empty());
      if (caller.isEmpty()) {
        return;
      }
      var startTime = caller.startTime;
      var timeInterval = DateTime.now().millisecondsSinceEpoch - startTime;
      if (timeInterval > 60 * 1000) {
        return;
      }

      if (callModel.isEmpty()) {
        callModel = model;
        addCallListener(model.callID);
      }

      List<ZegoUserInfo> callees = [];
      model.users.where((user) => user.callerID != user.userID).forEach((user) {
        callees.add(ZegoUserInfo(user.userID,
            user.userName.isNotEmpty ? user.userName : user.userID));
      });

      ZegoNotifyListenerParameter parameter = {};
      parameter['call_id'] = model.callID;
      parameter['call_type'] = model.callType.id;
      parameter['caller_id'] = caller.callerID;
      parameter['caller_name'] =
          caller.userName.isNotEmpty ? caller.userName : caller.userID;
      parameter['callees'] = callees;
      ZegoListenerManager.shared.receiveUpdate(notifyCallInvited, parameter);
    });
  }

  void addCallListener(String callID) {
    fcmTokenListenerSubscription = FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .onValue
        .listen((DatabaseEvent event) async {
      var snapshotValue = event.snapshot.value;

      var dict = snapshotValue as Map<dynamic, dynamic>;
      log('[firebase] call onValue: $dict');
      if(! dict.containsKey('call_status')) {
        return;
      }

      var callStatus = FirebaseCallStatusExtension
          .mapValue[dict['call_status'] as int] as FirebaseCallStatus;
      if (callStatus == FirebaseCallStatus.connecting) {
        return;
      }

      var model = ZegoFirebaseCallModel.fromMap(dict);
      var firebaseUser = model.getUser(user?.uid ?? "");
      if (firebaseUser.isEmpty()) {
        return;
      }

      ZegoNotifyListenerParameter parameter = {};

      if (firebaseUser.userID != firebaseUser.callerID &&
          firebaseUser.status == FirebaseCallStatus.canceled &&
          callModel.callStatus == FirebaseCallStatus.connecting) {
        // MARK: - callee receive call canceled
        parameter['call_id'] = model.callID;
        parameter['caller_id'] = firebaseUser.callerID;
        ZegoListenerManager.shared.receiveUpdate(notifyCallCanceled, parameter);
        callModel = ZegoFirebaseCallModel.empty();
      }

      if (firebaseUser.userID == firebaseUser.callerID &&
          firebaseUser.status == FirebaseCallStatus.calling &&
          callModel.callStatus == FirebaseCallStatus.connecting) {
        // MARK: - caller receive call accept
        var callee = model.users.firstWhere(
            (user) => user.userID != firebaseUser.userID,
            orElse: () => FirebaseCallUser.empty());
        if (callee.isEmpty()) {
          return;
        }

        parameter['call_id'] = model.callID;
        parameter['callee_id'] = callee.userID;
        ZegoListenerManager.shared.receiveUpdate(notifyCallAccept, parameter);
        callModel = ZegoFirebaseCallModel.empty();
      }

      if (firebaseUser.userID == firebaseUser.callerID &&
          (firebaseUser.status == FirebaseCallStatus.declined ||
              firebaseUser.status == FirebaseCallStatus.busy) &&
          callModel.callStatus == FirebaseCallStatus.connecting) {
        // MARK: - caller receive call decline
        var callee = model.users.firstWhere(
            (user) => user.userID != firebaseUser.userID,
            orElse: () => FirebaseCallUser.empty());
        if (callee.isEmpty()) {
          return;
        }
        if (callee.status != FirebaseCallStatus.declined &&
            callee.status != FirebaseCallStatus.busy) {
          return;
        }
        var declineType = callee.status == FirebaseCallStatus.declined
            ? ZegoDeclineType.kZegoDeclineTypeDecline
            : ZegoDeclineType.kZegoDeclineTypeBusy;
        parameter['call_id'] = model.callID;
        parameter['callee_id'] = callee.userID;
        parameter['type'] = declineType.id;
        ZegoListenerManager.shared.receiveUpdate(notifyCallDecline, parameter);
        callModel = ZegoFirebaseCallModel.empty();
      }

      if (model.callStatus == FirebaseCallStatus.ended &&
          callModel.callStatus == FirebaseCallStatus.calling) {
        // caller and callee receive call ended
        var other = model.users.firstWhere(
            (user) =>
                user.userID != firebaseUser.userID &&
                user.status != FirebaseCallStatus.ended,
            orElse: () => FirebaseCallUser.empty());
        parameter['call_id'] = model.callID;
        parameter['user_id'] = other.userID;
        ZegoListenerManager.shared.receiveUpdate(notifyCallEnd, parameter);
        callModel = ZegoFirebaseCallModel.empty();
      }

      if (firebaseUser.status == FirebaseCallStatus.connectingTimeout &&
          callModel.callStatus == FirebaseCallStatus.connecting) {
        // caller or callee receive connecting timeout

      }
      if (firebaseUser.status == FirebaseCallStatus.connectingTimeout &&
          callModel.callStatus == FirebaseCallStatus.calling) {
        // caller or callee receive calling timeout

      }
    });
  }

  void resetData() {
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

      user = null;
    }

    callModel = ZegoFirebaseCallModel.empty();
  }
}
