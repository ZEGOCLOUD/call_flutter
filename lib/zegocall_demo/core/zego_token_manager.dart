// Dart imports:
import 'dart:async';
import 'dart:developer';

// Package imports:
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../zegocall_uikit/core/manager/zego_call_manager.dart';

const storeUserID = "zego_user_id_key";
const storeKeyToken = "zego_token_key";
const storeKeyExpirySeconds = "zego_token_expiry_time_key";

class ZegoToken {
  String token = "";
  int expirySeconds = 0;
  String userID = "";

  ZegoToken.empty();

  ZegoToken(this.token, this.expirySeconds, this.userID);

  bool isValid() {
    if (token.isEmpty) {
      return false;
    }
    // 10 minutes buffer
    return expirySeconds >
        (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10 * 60);
  }

  @override
  String toString() {
    return "[zego token] user id:$userID, expiry seconds:$expirySeconds, "
        "token:$token";
  }
}

class ZegoTokenManager {
  ZegoToken token = ZegoToken.empty();

  static var shared = ZegoTokenManager();

  void init() async {
    token = await getTokenFromDisk();

    log('[token manager] init, token:${token.toString()}');
    onTokenSyncTimeout(null);
    Timer.periodic(const Duration(seconds: 60), onTokenSyncTimeout);
  }

  void onTokenSyncTimeout(timer) {
    if (!isNeedUpdate(token.userID)) {
      log('[token manager] token sync timeout, not need update');
      return;
    }

    updateToken(token.userID);
  }

  Future<String> updateToken(String userID) async {
    log('[token manager] update token, user id:$userID');

    //  24 hours
    var effectiveTimeInSeconds = 24 * 60 * 60;
    return getTokenFromServer(userID, effectiveTimeInSeconds).then((token) {
      saveToken(userID, token, effectiveTimeInSeconds);
      return token;
    });
  }

  void saveToken(
      String userID, String token, int effectiveTimeInSeconds) async {
    log('[token manager] save token, user id:$userID, token:$token, '
        'effectiveTimeInSeconds:$effectiveTimeInSeconds');

    var expirySeconds =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + effectiveTimeInSeconds;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(storeKeyToken, token);
    prefs.setInt(storeKeyExpirySeconds, expirySeconds);
    prefs.setString(storeUserID, userID);

    this.token = ZegoToken(token, expirySeconds, userID);
  }

  bool isNeedUpdate(String userID) {
    if (token.token.isEmpty) {
      return true;
    }

    if (token.userID != userID) {
      return true;
    }

    // if the token invalid under 60 minutes, then we update the token.
    if ((DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60 * 60) >
        token.expirySeconds) {
      return true;
    }

    return false;
  }

  Future<String> getToken(String userID) async {
    if (isNeedUpdate(userID)) {
      return updateToken(userID);
    }

    return token.token;
  }

  Future<ZegoToken> getTokenFromDisk() async {
    final prefs = await SharedPreferences.getInstance();

    var localUserID = ZegoCallManager.shared.localUserInfo?.userID ?? "";
    if (localUserID.isEmpty) {
      log('[token manager] get token from disk, local user id is empty');
      return ZegoToken.empty();
    }

    var oldUserID = prefs.getString(storeUserID) ?? "";
    if (oldUserID != localUserID) {
      log('[token manager] get token from disk, local user id:localUserID is different of'
          ' old user id:$oldUserID');
      return ZegoToken.empty();
    }

    var token = ZegoToken(
      prefs.getString(storeKeyToken) ?? "",
      prefs.getInt(storeKeyExpirySeconds) ?? 0,
      prefs.getString(storeUserID) ?? "",
    );
    log('[token manager] get token from disk, token:${token.toString()}');
    return token;
  }

  Future<String> getTokenFromServer(
      String userID, int effectiveTimeInSeconds) async {
    if (userID.isEmpty || effectiveTimeInSeconds < 0) {
      log('[token manager] get token from server, parameters is invalid');
      return "";
    }

    Map<String, dynamic> data = {
      'id': userID,
      'effective_time': effectiveTimeInSeconds
    };
    return await FirebaseFunctions.instance
        .httpsCallable('getToken')
        .call(data)
        .then((result) {
      var dict = result.data as Map<String, dynamic>;
      var token = dict['token'] as String;
      log('[token manager] get token from server, token:$token');
      return token;
    }, onError: (error) {
      log('[token manager] get token from server, error:$error');
      return "";
    });
  }
}
