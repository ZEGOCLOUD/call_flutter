import 'package:zego_call_flutter/model/zego_room_user_role.dart';

/// Class user information.
/// <p>Description: This class contains the user related information.</>
class ZegoUserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userID = "";

  /// User name, cannot be null.
  String displayName = "";
  String photoUrl = "";

  int lastChanged = 0;

  bool mic = false;
  bool camera = false;

  ZegoRoomUserRole userRole = ZegoRoomUserRole.roomUserRoleListener;

  ZegoUserInfo.empty();

  ZegoUserInfo(this.userID, this.displayName, this.lastChanged);

  bool isEmpty() {
    return userID.isEmpty || displayName.isEmpty;
  }

  ZegoUserInfo clone() => ZegoUserInfo(userID, displayName, lastChanged);

  ZegoUserInfo.fromJson(Map<String, dynamic> json)
      : userID = json['user_id'],
        displayName = json['display_name'],
        photoUrl = json['photo_url'],
        lastChanged = json['last_changed'];

  Map<String, dynamic> toJson() => {
        'user_id': userID,
        'display_name': displayName,
        'photo_url': photoUrl,
        'last_changed': lastChanged,
      };

  @override
  String toString() {
    return "UserInfo [user_id=$userID,display_name=$displayName,last_changed=$lastChanged]";
  }
}
