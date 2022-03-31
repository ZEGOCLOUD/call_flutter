// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/request/zego_firebase_manager.dart';
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
    FirebaseDatabase.instance
        .ref()
        .child('online_user')
        .orderByChild('last_changed')
        .onValue
        .listen((event) {
      userList.clear();
      userDic.clear();

      var map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map != null) {
        map.forEach((key, value) async {
          var userMap = Map<String, dynamic>.from(value);
          var user = DemoUserInfo.fromJson(userMap);
          userList.add(user);
          userDic[user.userID] = user;
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
      var map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map != null) {
        var userID = map['user_id'] as String? ?? "";
        var userName = map['display_name'] as String? ?? "";
        if (userID.isNotEmpty && !userDic.containsKey(userID)) {
          var userInfo = DemoUserInfo(userID, userName);
          userList.add(userInfo);
          userDic[userID] = userInfo;
        }

        notifyListeners();
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

      notifyListeners();
    });
  }
}
