import 'package:zego_call_flutter/model/zego_room_user_role.dart';

/// Class user information.
/// <p>Description: This class contains the user related information.</>
class ZegoUserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userID = "";

  /// User name, cannot be null.
  String userName = "";

  int last_changed = 0;

  String state = "offline";

  String? avatar = "";


  ZegoRoomUserRole userRole = ZegoRoomUserRole.roomUserRoleListener;

  ZegoUserInfo.empty();

  ZegoUserInfo(this.userID, this.userName, this.last_changed, this.state, this.avatar);

  bool isEmpty() {
    return userID.isEmpty || userName.isEmpty;
  }

  ZegoUserInfo clone() => ZegoUserInfo(userID, userName, last_changed, state, avatar);

  ZegoUserInfo.fromJson(Map<String, dynamic> json)
      : userID = json['uid'],
        userName = json['name'],
        last_changed = json['last_changed'],
        state = json['state'],
        avatar = json['avatar'];

  Map<String, dynamic> toJson() => {'userID': userID, 'userName': userName, 'last_changed': last_changed, 'state': state, 'avatar': avatar};

  @override
  String toString() {
    return "UserInfo [userId=$userID,userName=$userName,last_changed=$last_changed,state=$state, avatar=$avatar]";
  }
}
