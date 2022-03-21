import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:zego_call_flutter/model/zego_room_user_role.dart';
import 'package:zego_call_flutter/model/zego_user_info.dart';
import 'package:firebase_database/firebase_database.dart';


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
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        _setUserStatus(true);
      } else {
        _setUserStatus(false);
      }
    });
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
    totalUsersNum = 0;
  }

  onRoomEnter() {
    hadRoomReconnectedTimeout = false;
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



  void updateSpeakerSet(Set<String> speakerSet) {
  }

// databse
  Future<void> _setLocalUserInfo(bool online) async {
    var user = FirebaseAuth.instance.currentUser!;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/${user.uid}");
    var name = user.displayName;
    // var uid = user.uid;
    // var platform = "android";
    // if (Platform.isIOS) {
    //   platform = "ios";
    // }
    await ref.set({
      "username": name,
    });
  }

  Future<void> _setUserStatus(bool online) async {
    var user = FirebaseAuth.instance.currentUser!;
    DatabaseReference ref = FirebaseDatabase.instance.ref("status/${user.uid}");
    var state = online ? "online" : "offline";
    var time = DateTime.now().millisecondsSinceEpoch;
    var name = user.displayName;
    var uid = user.uid;
    var avatar = user.photoURL;
    await ref.set({
      "uid": uid,
      "name": name,
      "state": state,
      "last_changed": time,
      "avatar": avatar,
    });
  }

  Future<void> getOnlineUsers() async{
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('status/').get();
    var _userList = <ZegoUserInfo>[];
    if (snapshot.exists) {
      print(snapshot.value);
      var map = snapshot.value as Map<dynamic, dynamic>?;
      if (map != null) {
        map.forEach((key, value) async {
            var userMap = new Map<String, dynamic>.from(value);
            var model = ZegoUserInfo.fromJson(userMap);
            if (model.state == 'online') {
              _userList.add(model);
            }
        });
      }
      userList = _userList;
    } else {
      print('No data available.');
    }
  }

  Future<void> test() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('status/').get();
    if (snapshot.exists) {
      print(snapshot.value);
    } else {
      print('No data available.');
    }
  }



}
