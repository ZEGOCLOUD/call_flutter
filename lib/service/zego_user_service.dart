import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:zego_call_flutter/constants/zego_custom_command_constant.dart';
import 'package:zego_call_flutter/model/zego_room_user_role.dart';
import 'package:zego_call_flutter/model/zego_user_info.dart';
import 'package:zego_call_flutter/service/zego_room_manager.dart';
import 'package:zego_call_flutter/common/room_info_content.dart';

enum LoginState {
  loginStateLoggedOut,
  loginStateLoggingIn,
  loginStateLoggedIn,
  loginStateLoginFailed,
}

typedef LoginCallback = Function(int);
typedef MemberOfflineCallback = VoidCallback;
typedef MemberChangeCallback = Function(List<ZegoUserInfo>);

/// Class user information management.
/// <p>Description: This class contains the user information management logics, such as the logic of log in, log out,
/// get the logged-in user info, get the in-room user list, and add co-hosts, etc. </>
class ZegoUserService extends ChangeNotifier {
  MemberOfflineCallback? userOfflineCallback;

  /// In-room user list, can be used when displaying the user list in the room.
  List<ZegoUserInfo> userList = [];

  /// In-room user dictionary,  can be used to update user information.¬
  Map<String, ZegoUserInfo> userDic = <String, ZegoUserInfo>{};

  /// The local logged-in user information.
  ZegoUserInfo localUserInfo = ZegoUserInfo.empty();
  int totalUsersNum = 0;
  LoginState loginState = LoginState.loginStateLoggedOut;
  Set<String> _preSpeakerSet = {}; //Prevent frequent updates
  final Set<MemberChangeCallback> _memberJoinedCallbackSet = {};
  final Set<MemberChangeCallback> _memberLeaveCallbackSet = {};

  String notifyInfo = '';

  bool hadRoomReconnectedTimeout = false;

  void clearNotifyInfo() {
    notifyInfo = '';
  }

  ZegoUserService() {
  }

  registerMemberJoinCallback(MemberChangeCallback callback) {
    _memberJoinedCallbackSet.add(callback);
  }

  unregisterMemberJoinCallback(MemberChangeCallback callback) {
    _memberJoinedCallbackSet.remove(callback);
  }

  registerMemberLeaveCallback(MemberChangeCallback callback) {
    _memberLeaveCallbackSet.add(callback);
  }

  unregisterMemberLeaveCallback(MemberChangeCallback callback) {
    _memberLeaveCallbackSet.remove(callback);
  }

  onRoomLeave() {
    _preSpeakerSet.clear();
    userList.clear();
    userDic.clear();
    // We need to reuse local user id after leave room
    localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleListener;
    totalUsersNum = 0;
  }

  onRoomEnter() {
    hadRoomReconnectedTimeout = false;

    _updateUserRole(_preSpeakerSet);
  }

  ZegoUserInfo getUserByID(String userID) {
    var userInfo = userDic[userID] ?? ZegoUserInfo.empty();
    return userInfo.clone();
  }

  Future<int> fetchOnlineRoomUsersNum(String roomID) async {

    return 0;
  }

  /// User to log in.
  /// <p>Description: Call this method with user ID and username to log in to the LiveAudioRoom service.</>
  /// <p>Call this method at: After the SDK initialization</>
  ///
  /// @param userInfo refers to the user information. You only need to enter the user ID and username.
  /// @param token    refers to the authentication token. To get this, refer to the documentation:
  ///                 https://doc-en.zego.im/article/11648
  Future<int> login(ZegoUserInfo info, String token) async {


    return 0;
  }

  /// User to log out.
  /// <p>Description: This method can be used to log out from the current user account.</>
  /// <p>Call this method at: After the user login</>
  Future<int> logout() async {

    return 0;
  }

  /// Invite users to speak .
  /// <p>Description: This method can be called to invite users to take a speaker seat to speak, and the invitee will
  /// receive an invitation.</>
  /// <p>Call this method at:  After joining a room</>
  ///
  /// @param userID   refers to the ID of the user that you want to invite
  Future<int> sendInvitation(String userID) async {

    return 0;
  }

  void _onRoomMemberJoined(
      String roomID, List<Map<String, dynamic>> memberList) {
    var userInfoList = <ZegoUserInfo>[];
    for (final item in memberList) {
      var member = ZegoUserInfo.formJson(item);
      if (userDic.containsKey(member.userID)) {
        continue; //  duplicate user
      }

      userList.add(member);
      userDic[member.userID] = member;

      if (member.userID.isNotEmpty) {
        userInfoList.add(member.clone());
      }
    }

    _updateUserRole(_preSpeakerSet); //  memberList hasn't role attribute

    for (final callback in _memberJoinedCallbackSet) {
      callback([...userInfoList]);
    }

    notifyListeners();
  }

  void _onRoomMemberLeave(
      String roomID, List<Map<String, dynamic>> memberList) {
    var userInfoList = <ZegoUserInfo>[];
    for (final item in memberList) {
      var member = ZegoUserInfo.formJson(item);
      userList.removeWhere((element) => element.userID == member.userID);
      userDic.removeWhere((key, value) => key == member.userID);

      if (member.userID.isNotEmpty && localUserInfo.userID != member.userID) {
        userInfoList.add(member.clone());
      }
      for (final callback in _memberLeaveCallbackSet) {
        callback([...userInfoList]);
      }
    }
    notifyListeners();
  }

  void _onReceiveCustomPeerMessage(List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var messageJson = item['message'];
      Map<String, dynamic> messageDic = jsonDecode(messageJson);
      int actionType = messageDic['actionType'];
      if (zegoCustomCommandType.invitation ==
          ZegoCustomCommandTypeExtension.mapValue[actionType]) {
        // receive invitation
        RoomInfoContent toastContent = RoomInfoContent.empty();
        toastContent.toastType =
            RoomInfoType.roomHostInviteToSpeak; //  clear in receiver
        notifyInfo = json.encode(toastContent.toJson());
      }
    }
    notifyListeners();
  }

  void updateSpeakerSet(Set<String> speakerSet) {
    if (setEquals(_preSpeakerSet, speakerSet)) {
      return;
    }
    _preSpeakerSet = {...speakerSet};
    _updateUserRole(speakerSet);
  }

  void _updateUserRole(Set<String> speakerList) {
    var hostID = ZegoRoomManager.shared.roomService.roomInfo.hostID;
    // Leave room or init
    if (hostID.isEmpty) {
      return;
    }
    // Update local user role
    if (hostID == localUserInfo.userID) {
      localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleHost;
    } else if (speakerList.contains(localUserInfo.userID)) {
      localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleSpeaker;
    } else {
      localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleListener;
    }
    for (var user in userList) {
      if (user.userID == hostID) {
        user.userRole = ZegoRoomUserRole.roomUserRoleHost;
      } else if (speakerList.contains(user.userID)) {
        user.userRole = ZegoRoomUserRole.roomUserRoleSpeaker;
      } else {
        user.userRole = ZegoRoomUserRole.roomUserRoleListener;
      }
    }
    notifyListeners();
  }
}
