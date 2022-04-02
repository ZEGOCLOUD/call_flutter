// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
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
      print('[firebase] getOnlineUsers: $map');
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
    });
  }

  void addOnlineUsersListener() {
    FirebaseDatabase.instance
        .ref()
        .child('online_user')
        .onChildAdded
        .listen((event) {
      var map = event.snapshot.value as Map<dynamic, dynamic>?;
      print('[firebase] online_user add :$map');
      if (map != null) {
        var currentUser = FirebaseAuth.instance.currentUser!;

        var userID = map['user_id'] as String? ?? "";
        var userName = map['display_name'] as String? ?? "";
        if (userID == currentUser.uid) {
          return;
        }

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
      var map = event.snapshot.value as Map<dynamic, dynamic>?;
      print('[firebase] online_user removed :$map');
      if (map != null) {
        var userID = map['user_id'] as String? ?? "";

        userList.removeWhere((element) => element.userID == userID);
        userDic.remove(userID);

        notifyListeners();
      }
    });
  }
}
