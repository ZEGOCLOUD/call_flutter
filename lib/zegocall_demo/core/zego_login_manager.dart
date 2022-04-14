// Dart imports:
import 'dart:async';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:result_type/result_type.dart';

// Project imports:
import 'zego_token_manager.dart';
import 'zego_user_list_manager.dart';

typedef LoginResult = Result<User, int>;

mixin ZegoLoginManagerDelegate {
  onReceiveUserKickOut();
}

class ZegoLoginManager extends ChangeNotifier {
  static var shared = ZegoLoginManager();

  User? user;
  String fcmToken = "";
  ZegoLoginManagerDelegate? delegate;

  StreamSubscription<DatabaseEvent>? fcmTokenListenerSubscription;

  void init() {
    user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      this.user = user;

      if (null != this.user) {
        addUserToDatabase(this.user!);

        ZegoUserListManager.shared.init();
      }
    });
  }

  Future<LoginResult> login(String token) async {
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: token,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((UserCredential credential) {
      user = credential.user;
    });

    return Success(user!);
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();

    fcmTokenListenerSubscription?.cancel();

    resetData(removeUserData: true);

    user = null;
  }

  void addUserToDatabase(User user) {
    addUser(User user, String token) {
      var data = {
        "user_id": user.uid,
        "display_name": user.displayName,
        "token_id": token,
        "last_changed": DateTime.now().millisecondsSinceEpoch
      };
      var userRef =
          FirebaseDatabase.instance.ref('online_user').child(user.uid);
      userRef.set(data);
      userRef.onDisconnect().remove();

      addFcmTokenListener(user.uid);
    }

    if (fcmToken.isEmpty) {
      FirebaseMessaging.instance.getToken().then((token) {
        fcmToken = token ?? "";
        addUser(user, fcmToken);
      });
    } else {
      addUser(user, fcmToken);
    }
  }

  void addFcmTokenListener(String userID) {
    fcmTokenListenerSubscription = FirebaseDatabase.instance
        .ref('online_user')
        .child(userID)
        .child('token_id')
        .onValue
        .listen((DatabaseEvent event) async {
      var snapshotValue = event.snapshot.value;
      log('[firebase] fcm token onValue: $snapshotValue');

      var token = snapshotValue ?? "";  //  todo 一段时间后退出，处理
      if (token == fcmToken) {
        return;
      }

      resetData(removeUserData: false);

      logout();

      delegate?.onReceiveUserKickOut();
    });
  }

  void resetData({bool removeUserData = true}) {
    if (user != null) {
      FirebaseDatabase.instance
          .ref('push_token')
          .child(user!.uid)
          .child(fcmToken)
          .remove();

      fcmToken = "";

      FirebaseDatabase.instance.ref('online_user').onDisconnect().cancel();

      if (removeUserData) {
        FirebaseDatabase.instance.ref('online_user').child(user!.uid).remove();
      }
    }

    user = null;
    ZegoTokenManager.shared.saveToken("", 0);
  }
}
