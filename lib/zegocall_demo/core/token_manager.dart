// Dart imports:
import 'dart:async';

// Package imports:
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../logger.dart';
import '../../zegocall_uikit/core/manager/zego_call_manager.dart';

const storeUserID = "call_user_id_key";
const storeKeyToken = "call_token_key";
const storeKeyExpirySeconds = "call_token_expiry_time_key";

class Token {
  String token = "";
  int expirySeconds = 0;
  String userID = "";

  Token.empty();

  Token(this.token, this.expirySeconds, this.userID);

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
    return "[token manager] user id:$userID, expiry seconds:$expirySeconds, "
        "token:$token";
  }
}

class TokenManager {
  Token token = Token.empty();

  static var shared = TokenManager();

  void init() async {
    token = await getTokenFromDisk();

    logInfo('token:${token.toString()}');
    onTokenSyncTimeout(null);
    Timer.periodic(const Duration(seconds: 60), onTokenSyncTimeout);
  }

  void onTokenSyncTimeout(timer) {
    if (!isNeedUpdate(token.userID)) {
      logInfo('not need update');
      return;
    }

    updateToken(token.userID);
  }

  Future<String> updateToken(String userID) async {
    logInfo('user id:$userID');

    //  24 hours
    var effectiveTimeInSeconds = 24 * 60 * 60;
    return getTokenFromServer(userID, effectiveTimeInSeconds).then((token) {
      saveToken(userID, token, effectiveTimeInSeconds);
      return token;
    });
  }

  void saveToken(
      String userID, String token, int effectiveTimeInSeconds) async {
    logInfo(
        'user id:$userID, token:$token, effectiveTimeInSeconds:$effectiveTimeInSeconds');

    var expirySeconds =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + effectiveTimeInSeconds;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(storeKeyToken, token);
    prefs.setInt(storeKeyExpirySeconds, expirySeconds);
    prefs.setString(storeUserID, userID);

    this.token = Token(token, expirySeconds, userID);
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

  Future<Token> getTokenFromDisk() async {
    final prefs = await SharedPreferences.getInstance();

    var localUserID = ZegoCallManager.interface.localUserInfo.userID;
    if (localUserID.isEmpty) {
      logInfo('local user id is empty');
      return Token.empty();
    }

    var oldUserID = prefs.getString(storeUserID) ?? "";
    if (oldUserID != localUserID) {
      logInfo(
          'local user id:localUserID is different of old user id:$oldUserID');
      return Token.empty();
    }

    var token = Token(
      prefs.getString(storeKeyToken) ?? "",
      prefs.getInt(storeKeyExpirySeconds) ?? 0,
      prefs.getString(storeUserID) ?? "",
    );
    logInfo('token:${token.toString()}');
    return token;
  }

  Future<String> getTokenFromServer(
      String userID, int effectiveTimeInSeconds) async {
    if (userID.isEmpty || effectiveTimeInSeconds < 0) {
      logInfo('parameters is invalid, '
          'user id:$userID, effectiveTimeInSeconds:$effectiveTimeInSeconds');
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
      logInfo('token:$token');
      return token;
    }, onError: (error) {
      logInfo('error:$error');
      return "";
    });
  }
}
