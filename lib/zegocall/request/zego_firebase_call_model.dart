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
}

// FirebaseCallStatus.busy.id;

enum FirebaseCallType {
  voice,
  video,
}

extension FirebaseCallTypeExtension on FirebaseCallType {
  int get id {
    switch (this) {
      case FirebaseCallType.voice:
        return 1;
      case FirebaseCallType.video:
        return 2;
      default:
        return -1;
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

  bool isEmpty() => userID.isEmpty;
}

class ZegoFirebaseCallModel {
  String callID = "";

  FirebaseCallType callType = FirebaseCallType.voice;
  FirebaseCallStatus callStatus = FirebaseCallStatus.connecting;
  List<FirebaseCallUser> users = [];

  ZegoFirebaseCallModel.empty();

  bool isEmpty() => callID.isEmpty;

  void fromMap(Map<String, dynamic> dict) {
    callID = dict["call_id"] as String;
    callType = FirebaseCallType.values[dict["call_type"] as int];
    callStatus = FirebaseCallStatus.values[dict["call_status"] as int];

    var usersDict = dict["users"] as Map<String, dynamic>;
    usersDict.forEach((userID, userDict) {
      var user = FirebaseCallUser.empty();
      user.userID = userID;
      user.userName = userDict["user_name"] as String;
      user.callerID = userDict["caller_id"] as String;
      user.startTime = userDict["start_time"] as int;
      user.status = FirebaseCallStatus.values[dict["status"] as int];

      user.connectedTime = userDict["connected_time"] as int;
      user.finishTime = userDict["finish_time"] as int;
      user.heartbeatTime = userDict["heartbeat_time"] as int;

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
    return users.firstWhere((user) => user.userID == userID);
  }
}
