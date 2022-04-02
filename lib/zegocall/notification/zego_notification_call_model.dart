// Project imports:
import 'dart:convert';

import '../request/zego_firebase_call_model.dart';

class ZegoNotificationCallModel {
  String callID = "";
  String callerID = "";
  String callerName = "";
  FirebaseCallType callType = FirebaseCallType.voice;
  ZegoFirebaseCallModel callModel = ZegoFirebaseCallModel.empty();

  ZegoNotificationCallModel.fromMap(Map<dynamic, dynamic> dict) {
    callID = dict["call_id"] as String;
    callerID = dict["caller_id"] as String;
    callerName = dict["caller_name"] as String;
    callType = FirebaseCallTypeExtension
        .mapValue[int.parse(dict["call_type"] as String)] as FirebaseCallType;

    callModel.fromMap(Map.castFrom(json.decode(dict["call_data"])));
  }
}
