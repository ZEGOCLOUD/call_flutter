// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall_demo/constants/user_info.dart';

class ZegoUserListManager extends ChangeNotifier {
  static var shared = ZegoUserListManager();

  List<DemoUserInfo> userList = [];
  Map<String, DemoUserInfo> userDic = <String, DemoUserInfo>{};

  void init() {
    getOnlineUsers();
    addOnlineUsersListener();
  }

  DemoUserInfo getUserInfoByID(String userID) {
    return userDic[userID] ?? DemoUserInfo.empty();
  }

  void getOnlineUsers() {
    var usersQuery = FirebaseDatabase.instance
        .ref()
        .child('online_user')
        .orderByChild('last_changed');
    usersQuery.get().then((value) {
      userList.clear();
      userDic.clear();

      var map = value as Map<dynamic, dynamic>?;
      if (map != null) {
        map.forEach((key, value) async {
          var userMap = Map<String, dynamic>.from(value);
          var model = DemoUserInfo.fromJson(userMap);
          userList.add(model);
          userDic[model.userID] = model;
        });
      }
      notifyListeners();
    });
  }

  void addOnlineUsersListener() {
    FirebaseDatabase.instance
        .ref()
        .child('online_user')
        .onChildAdded
        .listen((event) {
      var userMap = event.snapshot.value as Map<String, dynamic>;
      var model = DemoUserInfo.fromJson(userMap);
      if (!userDic.containsKey(model.userID)) {
        userList.add(model);
        userDic[model.userID] = model;
      }
    });

    FirebaseDatabase.instance
        .ref()
        .child('online_user')
        .onChildRemoved
        .listen((event) {
      var userMap = event.snapshot.value as Map<String, dynamic>;
      var model = DemoUserInfo.fromJson(userMap);
      userList.removeWhere((element) => element.userID == model.userID);
      userDic.remove(model.userID);
    });
  }
}
