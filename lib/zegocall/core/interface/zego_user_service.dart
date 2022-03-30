// Dart imports:
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/delegate/zego_user_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';

/// Class user information management.
/// <p>Description: This class contains the user information management logics, such as the logic of log in, log out,
/// get the logged-in user info, get the in-room user list, and add co-hosts, etc. </>
abstract class IZegoUserService extends ChangeNotifier {
  /// In-room user list, can be used when displaying the user list in the room.
  List<ZegoUserInfo> userList = [];
  ZegoUserServiceDelegate? delegate;

  /// The local logged-in user information.
  ZegoUserInfo localUserInfo = ZegoUserInfo.empty();

  Future<int> login(ZegoUserInfo info, String token);

  Future<int> logout();

  Future<List<ZegoUserInfo>> getOnlineUsers();

  ZegoUserInfo getUserInfoByID(String userID);
}
