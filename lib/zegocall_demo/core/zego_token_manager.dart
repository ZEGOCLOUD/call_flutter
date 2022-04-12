// Dart imports:
import 'dart:async';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import './../../zegocall_uikit/core/zego_call_manager.dart';

const storeKeyToken = "zego_token_key";
const storeKeyExpirySeconds = "zego_token_expiry_time_key";

class ZegoToken {
  String token = "";
  int expirySeconds = 0;

  ZegoToken.empty();

  ZegoToken(this.token, this.expirySeconds);

  bool isValid() {
    if (token.isEmpty) {
      return false;
    }
    // 10 minutes buffer
    return expirySeconds >
        (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10 * 60);
  }
}

class ZegoTokenManager {
  ZegoToken token = ZegoToken.empty();

  static var shared = ZegoTokenManager();

  void init() async {
    token = await getTokenFromDisk();

    if (token.isValid()) {
      ZegoCallManager.shared.token = token.token;
    } else {
      onTokenSyncTimeout(null);
    }

    Timer.periodic(const Duration(seconds: 60), onTokenSyncTimeout);
  }

  void onTokenSyncTimeout(timer) {
    if (!isNeedUpdate()) {
      return;
    }

    var localUserID = ZegoCallManager.shared.localUserInfo?.userID ?? "";
    if (localUserID.isEmpty) {
      return;
    }

    //  24 hours
    var effectiveTimeInSeconds = 24 * 60 * 60;
    ZegoCallManager.shared
        .getToken(localUserID, effectiveTimeInSeconds)
        .then((token) {
      saveToken(token, effectiveTimeInSeconds);

      ZegoCallManager.shared.token = token;
    });
  }

  void saveToken(String token, int effectiveTimeInSeconds) async {
    var expirySeconds =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + effectiveTimeInSeconds;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(storeKeyToken, token);
    prefs.setInt(storeKeyExpirySeconds, expirySeconds);

    this.token = ZegoToken(token, expirySeconds);
  }

  bool isNeedUpdate() {
    if (token.token.isEmpty) {
      return true;
    }
    // if the token invalid under 60 minutes, then we update the token.
    if ((DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60 * 60) >
        token.expirySeconds) {
      return true;
    }

    return false;
  }

  Future<ZegoToken> getTokenFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    return ZegoToken(prefs.getString(storeKeyToken) ?? "",
        prefs.getInt(storeKeyExpirySeconds) ?? 0);
  }
}
