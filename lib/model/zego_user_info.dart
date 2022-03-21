import 'package:zego_call_flutter/model/zego_room_user_role.dart';

/// Class user information.
/// <p>Description: This class contains the user related information.</>
class ZegoUserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userID = "";

  /// User name, cannot be null.
  String displayName = "";

  int lastChanged = 0;

  String state = "offline";


  ZegoRoomUserRole userRole = ZegoRoomUserRole.roomUserRoleListener;

  ZegoUserInfo.empty();

  ZegoUserInfo(this.userID, this.displayName, this.lastChanged, this.state);

  bool isEmpty() {
    return userID.isEmpty || displayName.isEmpty;
  }

  ZegoUserInfo clone() => ZegoUserInfo(userID, displayName, lastChanged, state);

  ZegoUserInfo.fromJson(Map<String, dynamic> json)
      : userID = json['uid'],
        displayName = json['display_name'],
        lastChanged = json['last_changed'],
        state = json['state'];

  Map<String, dynamic> toJson() => {'userID': userID, 'display_name': displayName, 'last_changed': lastChanged, 'state': state};

  @override
  String toString() {
    return "UserInfo [userId=$userID,display_name=$displayName,last_changed=$lastChanged,state=$state]";
  }
}
