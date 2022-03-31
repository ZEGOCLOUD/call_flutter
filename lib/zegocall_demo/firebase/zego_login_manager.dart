// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:result_type/result_type.dart';

// Project imports:
import '../constants/user_info.dart';
import 'zego_user_list_manager.dart';

typedef LoginResult = Result<DemoUserInfo, int>;

class ZegoLoginManager extends ChangeNotifier {
  static var shared = ZegoLoginManager();

  DemoUserInfo user = DemoUserInfo.empty();

  Future<LoginResult> login(String token) async {
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: token,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((UserCredential credential) {
      user.userID = credential.user?.uid ?? "";
      user.userName = credential.user?.displayName ?? "";
    });

    ZegoUserListManager.shared.getOnlineUsers();

    return Success(user);
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();

    user = DemoUserInfo.empty();
  }
}
