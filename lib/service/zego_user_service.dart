import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:zego_call_flutter/model/zego_room_user_role.dart';
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
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        _setUserStatus(true);
      } else {
        _setUserStatus(false);
      }
    });
    _addConnectedObserve();
    _addCallObserve();
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

// databse
  Future<void> callUser(String uid, bool isVideo) async {
    ZegoUserInfo callee = userDic[uid] ?? ZegoUserInfo.empty();
    if (callee.userID.length == 0) {
      return;
    }
    var caller = FirebaseAuth.instance.currentUser!;
    var callTime = DateTime.now().millisecondsSinceEpoch;
    var callID = "caller.uid${callTime}";
    DatabaseReference ref = FirebaseDatabase.instance.ref("call/${callID}");
    var json = {
      caller.uid : {
        "username": caller.displayName,
        "role": 0,
        "heartbeat_time": 0,
        "connected_time": 0
      },
      callee.userID : {
        "username": callee.displayName,
        "role": 1,
        "heartbeat_time": 0,
        "connected_time": 0
      }
    };
    await ref.set(json);
  }

  Future<void> getOnlineUsers() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/').get();
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
          userDic[model.userID] = model;
        });
      }
      userList = _userList;
    } else {
      print('No data available.');
    }
  }

  Future<void> _setUserStatus(bool online) async {
    var user = FirebaseAuth.instance.currentUser!;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/${user.uid}");
    var state = online ? "online" : "offline";
    var time = DateTime
        .now()
        .millisecondsSinceEpoch;
    var name = user.displayName;
    var uid = user.uid;
    var platform = "android";
    if (Platform.isIOS) {
      platform = "ios";
    }
    await ref.set({
      "uid": uid,
      "display_name": name,
      "state": state,
      "last_changed": time,
    });

    await ref.onDisconnect().remove();
  }

  void _addConnectedObserve() {
    final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
    connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/${localUserInfo.userID}");

      if (localUserInfo.userID.length > 0) {
        if (connected) {
          _setUserStatus(true);
        } else {
          await ref.onDisconnect().remove();
        }
      }
    });
  }

  void _addCallObserve() {
    var caller = FirebaseAuth.instance.currentUser!;
    var callTime = DateTime.now().millisecondsSinceEpoch;
    var callID = "caller.uid${callTime}";
    DatabaseReference ref = FirebaseDatabase.instance.ref('call');
    ref.onChildAdded.listen((event) {
      debugPrint("The ${event.snapshot.key} dinosaur's score is ${event.snapshot.value}.");
    });
  }
}


