import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_call_flutter/service/zego_room_manager.dart';
import 'package:zego_call_flutter/common/room_info_content.dart';
import 'package:zego_call_flutter/constants/zego_room_constant.dart';
import 'package:zego_call_flutter/model/zego_room_info.dart';

import 'package:zego_call_flutter/model/zego_user_info.dart';

typedef RoomCallback = Function(int);
typedef RoomLeaveCallback = VoidCallback;
typedef RoomEnterCallback = VoidCallback;

/// Class LiveAudioRoom information management.
/// <p>Description: This class contains the room information management logics, such as the logic of create a room, join
/// a room, leave a room, disable the text chat in room, etc.</>
class ZegoRoomService extends ChangeNotifier {
  /// Room information, it will be assigned after join the room successfully. And it will be updated synchronously when
  /// the room status updates.
  RoomInfo roomInfo = RoomInfo('', '', '');
  RoomLeaveCallback? roomLeaveCallback;
  RoomEnterCallback? roomEnterCallback;

  List<ZegoUserInfo> userList = [];

  String notifyInfo = '';

  void clearNotifyInfo() {
    notifyInfo = '';
  }

  bool roomDisconnectSuccess = false;

  ZegoRoomService() {
  }

  String get _localUserID {
    return ZegoRoomManager.shared.userService.localUserInfo.userID;
  }

  String get _localUserName {
    return ZegoRoomManager.shared.userService.localUserInfo.displayName;
  }

  onRoomLeave() {}

  onRoomEnter() {
    roomDisconnectSuccess = false;
  }

  /// Join a room.
  /// <p>Description: This method can be used to join a room, the room must be an existing room.</>
  /// <p>Call this method at: After user logs in</>
  ///
  /// @param roomID   refers to the ID of the room you want to join, and cannot be null.
  /// @param token    token refers to the authentication token. To get this, see the documentation:
  ///                 https://doc-en.zego.im/article/11648
  Future<int> joinRoom(String roomID, String token) async {
    roomDisconnectSuccess = false;

    var config = ZegoRoomConfig.defaultConfig();
    config.token = token;
    config.maxMemberCount = 0;
    var user = ZegoUser(_localUserID, _localUserName);
    ZegoExpressEngine.instance.loginRoom(roomInfo.roomID, user, config: config);
    var soundConfig = ZegoSoundLevelConfig(1000, false);
    ZegoExpressEngine.instance.startSoundLevelMonitor(config: soundConfig);

    return 0;
  }

  /// Leave the room.
  /// <p>Description: This method can be used to leave the room you joined. The room will be ended when the Host
  /// leaves, and all users in the room will be forced to leave the room.</>
  /// <p>Call this method at: After joining a room</>
  Future<int> leaveRoom() async {
    // ZegoExpressEngine.instance.logoutRoom(roomID);

    return 0;
  }

}
