// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import './../constants/user_info.dart';

class ZegoUserListManager extends ChangeNotifier {
  static var shared = ZegoUserListManager();

  List<DemoUserInfo> userList = [];
  Map<String, DemoUserInfo> userDic = <String, DemoUserInfo>{};

  StreamSubscription? onlineUserSubscription;

  void init() {
    addOnlineUsersValueListener();
  }

  DemoUserInfo getUserInfoByID(String userID) {
    return userDic[userID] ?? DemoUserInfo.empty();
  }

  void addOnlineUsersValueListener() {
    onlineUserSubscription?.cancel();

    onlineUserSubscription = FirebaseDatabase.instance
        .ref()
        .child('online_user')
        .orderByChild('last_changed')
        .onValue
        .listen((event) {
      updateUser();
    });
  }

  void updateUser() {
    FirebaseDatabase.instance
        .ref()
        .child('online_user')
        .orderByChild('last_changed')
        .get()
        .then((value) {
      parseSnapshotData(value);
    });
  }

  void parseSnapshotData(DataSnapshot snapshot) {
    userList.clear();
    userDic.clear();

    var map = snapshot.value as Map<dynamic, dynamic>?;
    // log('[firebase] getOnlineUsers: $map');
    if (map != null) {
      var currentUser = FirebaseAuth.instance.currentUser!;

      map.forEach((key, value) async {
        var userMap = Map<String, dynamic>.from(value);
        var user = DemoUserInfo.fromJson(userMap);
        if (currentUser.uid == user.userID) {
          return;
        }
        userList.add(user);
        userDic[user.userID] = user;
      });
    }
    notifyListeners();
  }
}
