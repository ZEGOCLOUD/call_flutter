// Dart imports:
import 'dart:io';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import './../model/zego_user_info.dart';
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
  void setLocalUser(String userID, String userName) {
    localUserInfo = ZegoUserInfo(userID, userName);
  }

  @override
  Future<String> getToken(String userID) async {
    //todo
    return "";
  }

  ZegoUserInfo getUserInfoByID(String userID) {
    return userDic[userID] ?? ZegoUserInfo.empty();
  }

  Future<void> setUserStatus(bool online) async {
    var user = FirebaseAuth.instance.currentUser!;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("online_user/${user.uid}");

    localUserInfo.userName = user.displayName ?? "";
    localUserInfo.userID = user.uid;

    var platform = "android";
    if (Platform.isIOS) {
      platform = "ios";
    }
    await ref.set({
      "user_id": user.uid,
      "display_name": user.displayName,
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
