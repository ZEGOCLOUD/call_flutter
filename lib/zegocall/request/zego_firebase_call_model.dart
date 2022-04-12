// Dart imports:
import 'dart:core';

enum FirebaseCallStatus {
  connecting,
  calling,
  ended,
  declined,
  busy,
  canceled,
  connectingTimeout,
  callingTimeout,
  unknown,
}

extension FirebaseCallStatusExtension on FirebaseCallStatus {
  int get id {
    switch (this) {
      case FirebaseCallStatus.connecting:
        return 1;
      case FirebaseCallStatus.calling:
        return 2;
      case FirebaseCallStatus.ended:
        return 3;
      case FirebaseCallStatus.declined:
        return 4;
      case FirebaseCallStatus.busy:
        return 5;
      case FirebaseCallStatus.canceled:
        return 6;
      case FirebaseCallStatus.connectingTimeout:
        return 7;
      case FirebaseCallStatus.callingTimeout:
        return 8;
      default:
        return -1;
    }
  }

  static const Map<int, FirebaseCallStatus> mapValue = {
    -1: FirebaseCallStatus.unknown,
    1: FirebaseCallStatus.connecting,
    2: FirebaseCallStatus.calling,
    3: FirebaseCallStatus.ended,
    4: FirebaseCallStatus.declined,
    5: FirebaseCallStatus.busy,
    6: FirebaseCallStatus.canceled,
    7: FirebaseCallStatus.connectingTimeout,
    8: FirebaseCallStatus.callingTimeout,
  };
}

// FirebaseCallStatus.busy.id;

enum FirebaseCallType {
  voice,
  video,
}

extension FirebaseCallTypeExtension on FirebaseCallType {
  static const Map<int, FirebaseCallType> mapValue = {
    1: FirebaseCallType.voice,
    2: FirebaseCallType.video,
  };

  int get id {
    switch (this) {
      case FirebaseCallType.voice:
        return 1;
      case FirebaseCallType.video:
        return 2;
    }
  }
}

class FirebaseCallUser {
  String callerID = "";
  String userID = "";
  String userName = "";
  int startTime = 0;
  int connectedTime = 0;
  int finishTime = 0;
  int heartbeatTime = 0;
  FirebaseCallStatus status = FirebaseCallStatus.connecting;

  FirebaseCallUser.empty();

  FirebaseCallUser.clone(FirebaseCallUser object) {
    callerID = object.callerID;
    userID = object.userID;
    userName = object.userName;
    startTime = object.startTime;
    connectedTime = object.connectedTime;
    finishTime = object.finishTime;
    heartbeatTime = object.heartbeatTime;
    status = object.status;
  }

  bool isEmpty() => userID.isEmpty;
}

class ZegoFirebaseCallModel {
  String callID = "";

  FirebaseCallType callType = FirebaseCallType.voice;
  FirebaseCallStatus callStatus = FirebaseCallStatus.connecting;
  List<FirebaseCallUser> users = [];

  ZegoFirebaseCallModel.empty();

  bool isEmpty() => callID.isEmpty;

  ZegoFirebaseCallModel.fromMap(Map<dynamic, dynamic> dict) {
    callID = dict["call_id"] as String;

    callType = FirebaseCallTypeExtension.mapValue[dict["call_type"] as int]
        as FirebaseCallType;
    callStatus = FirebaseCallStatusExtension
        .mapValue[dict["call_status"] as int] as FirebaseCallStatus;

    var usersDict = dict["users"] as Map<dynamic, dynamic>;
    usersDict.forEach((userID, userDict) {
      var user = FirebaseCallUser.empty();
      user.userID = userID;
      user.userName = userDict["user_name"] as String;
      user.callerID = userDict["caller_id"] as String;
      user.startTime = userDict["start_time"] as int;
      user.status = FirebaseCallStatusExtension
          .mapValue[userDict["status"] as int] as FirebaseCallStatus;

      user.connectedTime = (userDict["connected_time"] ?? 0) as int;
      user.finishTime = (userDict["finish_time"] ?? 0) as int;
      user.heartbeatTime = (userDict["heartbeat_time"] ?? 0) as int;

      users.add(user);
    });
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> dict = {};

    dict["call_id"] = callID;
    dict["call_type"] = callType.id;
    dict["call_status"] = callStatus.id;

    Map<String, dynamic> usersDict = {};
    for (var user in users) {
      Map<String, dynamic> userDict = {};

      userDict["caller_id"] = user.callerID;
      userDict["user_id"] = user.userID;
      userDict["user_name"] = user.userName;
      userDict["start_time"] = user.startTime;
      userDict["connected_time"] = user.connectedTime;
      userDict["finish_time"] = user.finishTime;
      userDict["heartbeat_time"] = user.heartbeatTime;
      userDict["status"] = user.status.id;

      usersDict[user.userID] = userDict;
    }

    dict["users"] = usersDict;

    return dict;
  }

  FirebaseCallUser getUser(String userID) {
    return users.firstWhere((user) => user.userID == userID,
        orElse: () => FirebaseCallUser.empty());
  }
}
