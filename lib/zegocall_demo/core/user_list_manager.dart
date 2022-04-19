// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import './../constants/user_info.dart' as demo;

class UserListManager extends ChangeNotifier {
  static var shared = UserListManager();

  List<demo.UserInfo> userList = [];
  Map<String, demo.UserInfo> userDic = <String, demo.UserInfo>{};

  StreamSubscription? onlineUserSubscription;

  void init() {
    addOnlineUsersValueListener();
  }

  demo.UserInfo getUserInfoByID(String userID) {
    return userDic[userID] ?? demo.UserInfo.empty();
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
    if (map != null) {
      var currentUser = FirebaseAuth.instance.currentUser!;

      map.forEach((key, value) async {
        var userMap = Map<String, dynamic>.from(value);
        var user = demo.UserInfo.fromJson(userMap);
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
