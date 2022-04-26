// Dart imports:
import 'dart:convert';

// Project imports:
import '../request/zego_firebase_call_model.dart';

class ZegoNotificationModel {
  String callID = "";
  String callerID = "";
  String callerName = "";
  String callTypeID = "";
  String callStatusID = "";

  ZegoNotificationModel.empty();

  ZegoNotificationModel.fromMessageMap(Map<dynamic, dynamic> dict) {
    callID = dict["call_id"] as String;
    callerID = dict["caller_id"] as String;
    callerName = dict["caller_name"] as String;
    callTypeID = dict["call_type"] as String;

    var firebaseModel = ZegoFirebaseCallModel.fromMap(
        Map.castFrom(json.decode(dict["call_data"])));
    callStatusID = firebaseModel.callStatus.id.toString();
  }

  ZegoNotificationModel.fromMap(Map<String, String> data) {
    callID = data["call_id"] ?? "";
    callerID = data["caller_id"] ?? "";
    callerName = data["caller_name"] ?? "";
    callTypeID = data["call_type"] ?? "";
    callStatusID = data["call_status"] ?? "";
  }

  Map<String, String> toMap() {
    return {
      'call_id': callID,
      'caller_id': callerID,
      'caller_name': callerName,
      'call_type': callTypeID,
      'call_status': callStatusID,
    };
  }
}
