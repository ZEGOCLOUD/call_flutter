// Dart imports:
import 'dart:io';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/commands/zego_token_command.dart';
import '../interface/zego_user_service.dart';
import '../zego_call_defines.dart';
import './../model/zego_user_info.dart';

class ZegoUserServiceImpl extends IZegoUserService {
  /// In-room user dictionary,  can be used to update user information.¬
  Map<String, ZegoUserInfo> userDic = <String, ZegoUserInfo>{};

  @override
  void setLocalUser(String userID, String userName) {
    localUserInfo = ZegoUserInfo(userID, userName);
  }

  @override
  Future<RequestResult> getToken(String userID) async {
    var command = ZegoTokenCommand(userID);
    return command.execute();
  }

  @override
  ZegoUserInfo getUserInfoByID(String userID) {
    return userDic[userID] ?? ZegoUserInfo.empty();
  }
}
