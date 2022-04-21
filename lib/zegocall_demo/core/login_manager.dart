// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:result_type/result_type.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';

// Project imports:
import '../../logger.dart';
import '../../zegocall_uikit/core/manager/zego_call_manager.dart';
import '../../zegocall_uikit/utils/zego_navigation_service.dart';
import '../constants/page_constant.dart';
import 'user_list_manager.dart';

typedef LoginResult = Result<ZegoUserInfo, int>;

mixin LoginManagerDelegate {
  onReceiveUserKickOut();
}

class LoginManager extends ChangeNotifier {
  static var shared = LoginManager();

  ZegoUserInfo user = ZegoUserInfo.empty();
  String fcmToken = "";
  LoginManagerDelegate? delegate;

  StreamSubscription<DatabaseEvent>? fcmTokenListenerSubscription;

  void init() {
    user = convertFirebaseAuthUser(FirebaseAuth.instance.currentUser);
    if (!user.isEmpty()) {
      ZegoCallManager.shared.setLocalUser(user.userID, user.userName);
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      this.user = convertFirebaseAuthUser(user);

      if (!this.user.isEmpty()) {
        addUserToDatabase(this.user);

        UserListManager.shared.init();
      }
    });
  }

  ZegoUserInfo convertFirebaseAuthUser(User? user) {
    return ZegoUserInfo(user?.uid ?? "", user?.displayName ?? "");
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
      user = convertFirebaseAuthUser(credential.user);
    });

    return Success(user);
  }

  void logout() async {
    await GoogleSignIn().signOut();

    await FirebaseAuth.instance.signOut();

    fcmTokenListenerSubscription?.cancel();

    resetData(removeUserData: true);

    user = ZegoUserInfo.empty();

    final ZegoNavigationService _navigationService =
        locator<ZegoNavigationService>();
    var context = _navigationService.navigatorKey.currentContext!;
    Navigator.pushReplacementNamed(context, PageRouteNames.login);
  }

  void addUserToDatabase(ZegoUserInfo user) {
    addUser(ZegoUserInfo user, String token) {
      var data = {
        "user_id": user.userID,
        "display_name": user.userName,
        "token_id": token,
        "last_changed": DateTime.now().millisecondsSinceEpoch
      };
      var userRef =
          FirebaseDatabase.instance.ref('online_user').child(user.userID);
      userRef.set(data);
      userRef.onDisconnect().remove();

      addFcmTokenListener(user.userID);
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
      logInfo('fcm token onValue: $snapshotValue');

      var token = snapshotValue ?? "";
      if (token == fcmToken) {
        return;
      }

      resetData(removeUserData: false);

      logout();

      ZegoCallManager.interface.resetCallData();

      delegate?.onReceiveUserKickOut();
    });
  }

  void resetData({bool removeUserData = true}) {
    if (!user.isEmpty()) {
      FirebaseDatabase.instance
          .ref('push_token')
          .child(user.userID)
          .child(fcmToken)
          .remove();

      fcmToken = "";

      FirebaseDatabase.instance.ref('online_user').onDisconnect().cancel();

      if (removeUserData) {
        FirebaseDatabase.instance
            .ref('online_user')
            .child(user.userID)
            .remove();
      }
    }

    user = ZegoUserInfo.empty();
  }
}
