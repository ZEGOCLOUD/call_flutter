import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:zego_call_flutter/model/zego_user_info.dart';
import 'package:firebase_database/firebase_database.dart';

/// Class user information management.
/// <p>Description: This class contains the user information management logics, such as the logic of log in, log out,
/// get the logged-in user info, get the in-room user list, and add co-hosts, etc. </>
class ZegoUserService extends ChangeNotifier {
  /// In-room user list, can be used when displaying the user list in the room.
  List<ZegoUserInfo> userList = [];

  /// In-room user dictionary,  can be used to update user information.¬
  Map<String, ZegoUserInfo> userDic = <String, ZegoUserInfo>{};

  /// The local logged-in user information.
  ZegoUserInfo localUserInfo = ZegoUserInfo.empty();

  String notifyInfo = '';
  bool hadRoomReconnectedTimeout = false;

  void clearNotifyInfo() {
    notifyInfo = '';
  }

  ZegoUserService() {
    _setUserStatus(FirebaseAuth.instance.currentUser != null);
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        _setUserStatus(true);
      } else {
        _setUserStatus(false);
      }
    });
    _addConnectedObserve();
  }

  onRoomLeave() {
    userList.clear();
    userDic.clear();
  }

  onRoomEnter() {
    hadRoomReconnectedTimeout = false;
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

  Future<void> getOnlineUsers() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('online_user/').get();
    var _userList = <ZegoUserInfo>[];
    if (snapshot.exists) {
      var map = snapshot.value as Map<dynamic, dynamic>?;
      if (map != null) {
        map.forEach((key, value) async {
          var userMap = Map<String, dynamic>.from(value);
          var model = ZegoUserInfo.fromJson(userMap);
          _userList.add(model);
          userDic[model.userID] = model;
        });
      }
      userList = _userList;
      notifyListeners();
    } else {
      print('No data available.');
    }

    notifyListeners();
  }

  Future<void> _setUserStatus(bool online) async {
    var user = FirebaseAuth.instance.currentUser!;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("online_user/${user.uid}");

    localUserInfo.displayName = user.displayName ?? "";
    localUserInfo.userID = user.uid;
    localUserInfo.photoUrl = user.photoURL ?? "";

    var platform = "android";
    if (Platform.isIOS) {
      platform = "ios";
    }
    await ref.set({
      "user_id": user.uid,
      "display_name": user.displayName,
      "photo_url": user.photoURL,
      "last_changed": DateTime.now().millisecondsSinceEpoch,
    });

    // await ref.onDisconnect().remove();
  }

  void _addConnectedObserve() {
    final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
    connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("online_user/${localUserInfo.userID}");

      if (localUserInfo.userID.isNotEmpty) {
        if (connected) {
          _setUserStatus(true);
        } else {
          // await ref.onDisconnect().remove();
        }
      }
    });
  }
}
