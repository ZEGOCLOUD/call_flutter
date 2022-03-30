// Dart imports:
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/delegate/zego_user_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import '../interface/zego_user_service.dart';

class ZegoUserServiceImpl extends IZegoUserService {
  /// In-room user dictionary,  can be used to update user information.¬
  Map<String, ZegoUserInfo> userDic = <String, ZegoUserInfo>{};

  ZegoUserServiceImpl() : super() {
    setUserStatus(FirebaseAuth.instance.currentUser != null);
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        setUserStatus(true);
      } else {
        setUserStatus(false);
      }
    });
    addConnectedObserve();
  }

  @override
  Future<int> login(ZegoUserInfo info, String token) async {
    return 0;
  }

  @override
  Future<int> logout() async {
    return 0;
  }

  @override
  Future<List<ZegoUserInfo>> getOnlineUsers() async {
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

    return userList;
  }

  @override
  ZegoUserInfo getUserInfoByID(String userID) {
    return userDic[userID] ?? ZegoUserInfo.empty();
  }

  Future<void> setUserStatus(bool online) async {
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

  void addConnectedObserve() {
    final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
    connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("online_user/${localUserInfo.userID}");

      if (localUserInfo.userID.isNotEmpty) {
        if (connected) {
          setUserStatus(true);
        } else {
          // await ref.onDisconnect().remove();
        }
      }
    });
  }
}
