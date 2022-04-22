// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:result_type/result_type.dart';

// Project imports:
import '../../logger.dart';
import '../command/zego_request_protocol.dart';
import '../core/model/zego_user_info.dart';
import '../core/zego_call_defines.dart';
import '../listener/zego_listener.dart';
import '../listener/zego_listener_manager.dart';
import 'zego_firebase_call_model.dart';

class ZegoFireBaseManager extends ZegoRequestProtocol {
  static var shared = ZegoFireBaseManager();

  String fcmToken = "";
  User? user;
  Map<String, ZegoFirebaseCallModel> modelDict = {};

  StreamSubscription<DatabaseEvent>? incomingListenerSubscription;
  Map<String, StreamSubscription<DatabaseEvent>?> callListenerSubscriptions =
      {};

  Map<String, Function(RequestParameterType)> functionMap = {};

  @override
  Future<RequestResult> request(
      String path, RequestParameterType parameters) async {
    logInfo('path:$path, parameters:$parameters');

    if (!functionMap.containsKey(path)) {
      return Failure(ZegoError.failed);
    }

    return functionMap[path]!(parameters);
  }

  void init() {
    user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      this.user = user;

      if (null != this.user) {
        addFcmTokenToDatabase();
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
  }

  void resetData() {
    incomingListenerSubscription?.cancel();
    callListenerSubscriptions.forEach((key, value) {
      value?.cancel();
    });

    if (user != null) {
      FirebaseDatabase.instance
          .ref('push_token')
          .child(user!.uid)
          .child(fcmToken)
          .remove();

      fcmToken = "";
      user = null;
    }

    modelDict.clear();
  }

  Future<RequestResult> callUsers(RequestParameterType parameters) async {
    final callID = parameters["call_id"] as String? ?? "";
    final caller =
        parameters["caller"] as ZegoUserInfo? ?? ZegoUserInfo.empty();
    final callees = parameters["callees"] as List<ZegoUserInfo>? ?? [];
    final callType = FirebaseCallTypeExtension
        .mapValue[parameters["type"] as int? ?? FirebaseCallType.voice.id]!;
    if (callID.isEmpty || caller.isEmpty() || callees.isEmpty) {
      logInfo('parameters is invalid');
      return Failure(ZegoError.paramInvalid);
    }

    var callModel = ZegoFirebaseCallModel.empty();
    callModel.callID = callID;
    callModel.callType = callType;
    callModel.callStatus = FirebaseCallStatus.connecting;
    callModel.users.clear();

    var firebaseCaller = ZegoFirebaseCallUser.empty();
    firebaseCaller.callerID = caller.userID;
    firebaseCaller.userID = caller.userID;
    firebaseCaller.userName = caller.userName;
    firebaseCaller.startTime = DateTime.now().millisecondsSinceEpoch;
    firebaseCaller.status = FirebaseCallStatus.connecting;
    callModel.users.add(firebaseCaller);

    for (var user in callees) {
      var callee = ZegoFirebaseCallUser.clone(firebaseCaller);
      callee.userID = user.userID;
      callee.userName = user.userName;
      callModel.users.add(callee);
    }

    logInfo('call id:$callID, data:${callModel.toMap()}');
    await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .set(callModel.toMap())
        .then((value) {
      modelDict[callID] = callModel;
      logInfo('model dict add $callID');

      addCallListener(callID);
    });

    return Success("");
  }

  Future<RequestResult> cancelCall(RequestParameterType parameters) async {
    final calleeID = parameters["callee_id"] as String? ?? "";
    final callID = parameters["call_id"] as String? ?? "";
    final userID = parameters["id"] as String? ?? "";
    if (calleeID.isEmpty || callID.isEmpty || userID.isEmpty) {
      logInfo('parameters is invalid');
      return Failure(ZegoError.paramInvalid);
    }

    if (!modelDict.containsKey(callID)) {
      logInfo('model dict does not contain $callID');
      return Failure(ZegoError.failed);
    }

    var model = modelDict[callID]!;
    model.callStatus = FirebaseCallStatus.ended;

    model.getUser(userID).status = FirebaseCallStatus.ended;
    model.getUser(calleeID).status = FirebaseCallStatus.ended;

    return await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .runTransaction((mutableData) {
      if (null == mutableData) {
        return Transaction.abort();
      }
      return Transaction.success(model.toMap());
    }).then((TransactionResult result) {
      if (result.committed) {
        modelDict.remove(callID);
        logInfo('model dict remove $callID');

        return Success("");
      } else {
        return Failure(ZegoError.failed);
      }
    });
  }

  Future<RequestResult> acceptCall(RequestParameterType parameters) async {
    final callID = parameters["call_id"] as String? ?? "";
    if (callID.isEmpty) {
      logInfo('parameters is invalid');
      return Failure(ZegoError.paramInvalid);
    }

    if (!modelDict.containsKey(callID)) {
      logInfo('model dict does not contain $callID');
      return Failure(ZegoError.failed);
    }

    var model = modelDict[callID]!;
    model.callStatus = FirebaseCallStatus.calling;
    for (var user in model.users) {
      user.status = FirebaseCallStatus.calling;
      user.connectedTime = DateTime.now().millisecondsSinceEpoch;
    }

    return await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .runTransaction((mutableData) {
      if (null == mutableData) {
        return Transaction.abort();
      }
      return Transaction.success(model.toMap());
    }).then((TransactionResult result) {
      if (result.committed) {
        return Success("");
      } else {
        return Failure(ZegoError.failed);
      }
    });
  }

  Future<RequestResult> declineCall(RequestParameterType parameters) async {
    final callID = parameters["call_id"] as String;
    final type = ZegoDeclineTypeExtension.mapValue[
        parameters["type"] as int? ?? ZegoDeclineType.kZegoDeclineTypeDecline];
    if (callID.isEmpty) {
      logInfo('parameters is invalid');
      return Failure(ZegoError.paramInvalid);
    }

    if (!modelDict.containsKey(callID)) {
      logInfo('model dict does not contain $callID');
      return Failure(ZegoError.failed);
    }

    return await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .runTransaction((mutableData) {
      if (null == mutableData) {
        return Transaction.abort();
      }

      var mapData = mutableData as Map<dynamic, dynamic>;
      var model = ZegoFirebaseCallModel.fromMap(mapData);
      if (model.isEmpty()) {
        return Transaction.abort();
      }

      model.callStatus = FirebaseCallStatus.ended;
      for (var user in model.users) {
        user.status = (type == ZegoDeclineType.kZegoDeclineTypeDecline)
            ? FirebaseCallStatus.declined
            : FirebaseCallStatus.busy;
      }

      return Transaction.success(model.toMap());
    }).then((TransactionResult result) {
      if (result.committed) {
        modelDict.remove(callID);
        logInfo('model dict remove $callID');

        return Success("");
      } else {
        return Failure(ZegoError.failed);
      }
    });
  }

  Future<RequestResult> endCall(RequestParameterType parameters) async {
    final callID = parameters["call_id"] as String? ?? "";
    if (callID.isEmpty) {
      logInfo('parameters is invalid');
      return Failure(ZegoError.paramInvalid);
    }

    if (!modelDict.containsKey(callID)) {
      logInfo('model dict does not contain $callID');
      return Failure(ZegoError.failed);
    }

    var model = modelDict[callID]!;
    model.callStatus = FirebaseCallStatus.ended;
    for (var user in model.users) {
      user.status = FirebaseCallStatus.ended;
      user.finishTime = DateTime.now().millisecondsSinceEpoch;
    }

    return await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .runTransaction((mutableData) {
      if (null == mutableData) {
        return Transaction.abort();
      }
      return Transaction.success(model.toMap());
    }).then((TransactionResult result) {
      if (result.committed) {
        modelDict.remove(callID);
        logInfo('model dict remove $callID');

        return Success("");
      } else {
        return Failure(ZegoError.failed);
      }
    });
  }

  Future<RequestResult> heartbeat(RequestParameterType parameters) async {
    final userID = parameters["id"] as String? ?? "";
    final callID = parameters["call_id"] as String? ?? "";
    if (userID.isEmpty || callID.isEmpty) {
      logInfo('parameters is invalid');
      return Failure(ZegoError.paramInvalid);
    }

    if (!modelDict.containsKey(callID)) {
      logInfo('model dict does not contain $callID');
      return Failure(ZegoError.failed);
    }

    var callModel = modelDict[callID]!;
    if (callModel.callStatus != FirebaseCallStatus.calling ||
        callModel.callID != callID) {
      return Success("");
    }

    var user = callModel.getUser(userID);
    if (user.isEmpty()) {
      logInfo('user is empty');
      return Failure(ZegoError.failed);
    }
    user.heartbeatTime = DateTime.now().millisecondsSinceEpoch;

    logInfo('update heartbeat:${user.heartbeatTime}');
    await FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .child('users')
        .child(userID)
        .update({'heartbeat_time': user.heartbeatTime});

    return Success("");
  }

  void addFcmTokenToDatabase() {
    addFcmToken(String token) {
      if (null == user) {
        logInfo('user is null');
        return;
      }
      if (token.isEmpty) {
        logInfo('token is empty');
        return;
      }

      var platform = "android";
      if (Platform.isIOS) {
        platform = "ios";
      }
      var fcmTokenRef = FirebaseDatabase.instance
          .ref('push_token')
          .child(user!.uid);
      var tokenData = {
        token: {
          "device_type": platform,
          "token_id": fcmToken,
          "user_id": user!.uid
        }
      };
      fcmTokenRef.set(tokenData);
    }

    if (fcmToken.isEmpty) {
      FirebaseMessaging.instance.getToken().then((token) {
        if (null == token) {
          logInfo('messaging get token is null');
          return;
        }
        fcmToken = token;
        addFcmToken(fcmToken);
      });
    } else {
      addFcmToken(fcmToken);
    }
  }

  // a incoming call will trigger this method
  void addIncomingCallListener() {
    incomingListenerSubscription = FirebaseDatabase.instance
        .ref('call')
        .onChildAdded
        .listen((DatabaseEvent event) async {
      var snapshotValue = event.snapshot.value;
      if (null == snapshotValue) {
        logInfo('snapshot value is null');
        return;
      }

      var callDict = snapshotValue as Map<dynamic, dynamic>;

      var callStatus = FirebaseCallStatusExtension.mapValue[
              callDict['call_status'] as int? ?? FirebaseCallStatus.unknown.id]
          as FirebaseCallStatus;
      if (callStatus != FirebaseCallStatus.connecting) {
        logInfo('call status is not connecting');
        return;
      }

      var model = ZegoFirebaseCallModel.fromMap(callDict);
      if (model.isEmpty()) {
        logInfo('model is empty');
        return;
      }
      var firebaseUser = model.getUser(user?.uid ?? "");
      if (firebaseUser.userID == firebaseUser.callerID) {
        logInfo('user id is same as caller id, '
            '$firebaseUser');
        return;
      }

      logInfo('call dict: $callDict');

      var caller = model.users.firstWhere(
          (user) => user.callerID == user.userID,
          orElse: () => ZegoFirebaseCallUser.empty());
      if (caller.isEmpty()) {
        logInfo('caller is empty');
        return;
      }

      // if the start time of call is beyond 60s means this call is ended.
      var startTime = caller.startTime;
      var timeInterval = DateTime.now().millisecondsSinceEpoch - startTime;
      if (timeInterval > 60 * 1000) {
        logInfo('start time of call is beyond 60s means this call is ended.');
        return;
      }

      if (!modelDict.containsKey(model.callID)) {
        logInfo('model dict does not contain ${model.callID}, add to dict.');
        modelDict[model.callID] = model;
        logInfo('model dict add ${model.callID}');

        addCallListener(model.callID);
      }

      var callerUser = ZegoUserInfo(caller.callerID,
          caller.userName.isNotEmpty ? caller.userName : caller.userID);
      List<ZegoUserInfo> callees = [];
      model.users.where((user) => user.callerID != user.userID).forEach((user) {
        callees.add(ZegoUserInfo(user.userID,
            user.userName.isNotEmpty ? user.userName : user.userID));
      });
      ZegoNotifyListenerParameter parameter = {};
      parameter['call_id'] = model.callID;
      parameter['call_type'] = model.callType.id;
      parameter['caller'] = callerUser;
      parameter['callees'] = callees;
      ZegoListenerManager.shared.receiveUpdate(notifyCallInvited, parameter);
    });
  }

  void addCallListener(String callID) {
    callListenerSubscriptions[callID] = FirebaseDatabase.instance
        .ref('call')
        .child(callID)
        .onValue
        .listen((DatabaseEvent event) async {
      var snapshotValue = event.snapshot.value;
      if (null == snapshotValue) {
        logInfo('snapshot value is null');

        if (!modelDict.containsKey(event.snapshot.key)) {
          logInfo('model dict has not ${event.snapshot.key}');
          return;
        }

        var model = modelDict[event.snapshot.key]!;
        var myUser = model.getUser(user?.uid ?? "");
        if (myUser.isEmpty()) {
          logInfo('user is empty');
          return;
        }

        var otherUser = model.users.firstWhere(
            (user) => user.userID != myUser.userID,
            orElse: () => ZegoFirebaseCallUser.empty());
        if (otherUser.isEmpty()) {
          logInfo('otherUser is empty');
          return;
        }

        // if the call data is nil, means this call is ended.
        if (model.callStatus == FirebaseCallStatus.connecting) {
          // if the current status is `connecting`:
          // 1. user decline the call
          // 2. user cancel the call

          // caller receive the declined message.
          if (myUser.callerID == myUser.userID) {
            onReceiveDeclinedNotify(model.callID, otherUser.userID,
                ZegoDeclineType.kZegoDeclineTypeDecline.id);
          }
          // callee receive the canceled message.
          else {
            onReceiveCanceledNotify(model.callID, otherUser.callerID);
          }
        } else if (model.callStatus == FirebaseCallStatus.calling) {
          // if the current status is `calling`
          // 1. user ended the call
          onReceiveEndedNotify(model.callID, otherUser.userID);
        }

        modelDict.remove(model.callID);
        logInfo('model dict remove ${model.callID}');

        return;
      }

      var callDict = snapshotValue as Map<dynamic, dynamic>;

      var callStatus = FirebaseCallStatusExtension.mapValue[
              callDict['call_status'] as int? ?? FirebaseCallStatus.unknown.id]
          as FirebaseCallStatus;
      if (callStatus == FirebaseCallStatus.connecting) {
        logInfo('call status is connecting');
        return;
      }

      var model = ZegoFirebaseCallModel.fromMap(callDict);
      var myUser = model.getUser(user?.uid ?? "");
      if (myUser.isEmpty()) {
        logInfo('my user is empty');
        return;
      }
      var otherUser = model.users.firstWhere(
          (user) => user.userID != myUser.userID,
          orElse: () => ZegoFirebaseCallUser.empty());
      if (otherUser.isEmpty()) {
        logInfo('other user is empty');
        return;
      }

      if (!modelDict.containsKey(model.callID)) {
        logInfo('old model has not ${model.callID}');
        return;
      }
      var oldModel = modelDict[model.callID]!;

      if (myUser.userID != myUser.callerID &&
          myUser.status == FirebaseCallStatus.canceled &&
          oldModel.callStatus == FirebaseCallStatus.connecting) {
        // callee receive call canceled
        onReceiveCanceledNotify(model.callID, myUser.callerID);
      } else if (myUser.userID == myUser.callerID &&
          myUser.status == FirebaseCallStatus.calling &&
          oldModel.callStatus == FirebaseCallStatus.connecting) {
        // caller receive call accept
        onReceiveAcceptedNotify(model, otherUser.userID);
      } else if (myUser.userID == myUser.callerID &&
          (myUser.status == FirebaseCallStatus.declined ||
              myUser.status == FirebaseCallStatus.busy) &&
          oldModel.callStatus == FirebaseCallStatus.connecting) {
        // caller receive call decline
        if (otherUser.status != FirebaseCallStatus.declined &&
            otherUser.status != FirebaseCallStatus.busy) {
          return;
        }
        var declineType = otherUser.status == FirebaseCallStatus.declined
            ? ZegoDeclineType.kZegoDeclineTypeDecline
            : ZegoDeclineType.kZegoDeclineTypeBusy;
        onReceiveDeclinedNotify(model.callID, otherUser.userID, declineType.id);
      } else if (model.callStatus == FirebaseCallStatus.ended &&
          oldModel.callStatus == FirebaseCallStatus.calling) {
        // caller and callee receive call ended
        if (otherUser.status != FirebaseCallStatus.ended) {
          return;
        }
        onReceiveEndedNotify(model.callID, otherUser.userID);
      } else if (myUser.status == FirebaseCallStatus.connectingTimeout &&
          oldModel.callStatus == FirebaseCallStatus.connecting) {
        // caller or callee receive connecting timeout

      } else if (myUser.status == FirebaseCallStatus.connectingTimeout &&
          oldModel.callStatus == FirebaseCallStatus.calling) {
        // caller or callee receive calling timeout
        if (myUser.heartbeatTime > 0 && otherUser.heartbeatTime > 0) {
          if (myUser.heartbeatTime - otherUser.heartbeatTime > 60 * 1000) {
            onReceiveTimeoutNotify(model.callID, otherUser.userID);
            event.snapshot.ref
                .update({"call_status": FirebaseCallStatus.ended.id});
          }
        }
        modelDict[model.callID] = model;
        logInfo('model dict add ${model.callID}');
      }
    });
  }

  /// callee receive the call canceled
  onReceiveCanceledNotify(String callID, String callerID) {
    Map<String, dynamic> data = {"call_id": callID, "caller_id": callerID};
    ZegoListenerManager.shared.receiveUpdate(notifyCallCanceled, data);

    modelDict.remove(callID);
    logInfo('model dict remove $callID');
  }

  /// caller receive the accepted
  onReceiveAcceptedNotify(ZegoFirebaseCallModel model, String calleeID) {
    Map<String, dynamic> data = {
      "call_id": model.callID,
      "callee_id": calleeID
    };
    ZegoListenerManager.shared.receiveUpdate(notifyCallAccept, data);

    modelDict[model.callID] = model;
    logInfo('model dict add ${model.callID}');
  }

  /// caller receive the callee declined the call
  onReceiveDeclinedNotify(String callID, String calleeID, int type) {
    Map<String, dynamic> data = {
      "call_id": callID,
      "callee_id": calleeID,
      "type": type
    };
    ZegoListenerManager.shared.receiveUpdate(notifyCallDecline, data);

    modelDict.remove(callID);
    logInfo('model dict remove $callID');
  }

  /// receive other user ended the call.
  onReceiveEndedNotify(String callID, String otherUserID) {
    Map<String, dynamic> data = {"call_id": callID, "user_id": otherUserID};
    ZegoListenerManager.shared.receiveUpdate(notifyCallEnd, data);

    modelDict.remove(callID);
    logInfo('model dict remove $callID');
  }

  onReceiveTimeoutNotify(String callID, String otherUserID) {
    Map<String, dynamic> data = {"call_id": callID, "user_id": otherUserID};
    ZegoListenerManager.shared.receiveUpdate(notifyCallTimeout, data);
  }
}
