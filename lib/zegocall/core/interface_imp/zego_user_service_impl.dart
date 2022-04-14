// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:result_type/result_type.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import './../../../zegocall/core/commands/zego_token_command.dart';
import './../../../zegocall/core/interface/zego_event_handler.dart';
import './../../../zegocall/core/interface_imp/zego_stream_service_impl.dart';
import './../interface/zego_user_service.dart';
import './../manager/zego_service_manager.dart';
import './../model/zego_user_info.dart';
import './../zego_call_defines.dart';

class ZegoUserServiceImpl extends IZegoUserService with ZegoEventHandler {
  /// In-room user dictionary,  can be used to update user information.¬
  Map<String, ZegoUserInfo> userDic = <String, ZegoUserInfo>{};

  @override
  void init() {
    ZegoServiceManager.shared.addExpressEventHandler(this);
  }

  @override
  void setLocalUser(String userID, String userName) {
    assert(
        userID.length <= 64,
        " The User ID length must be less than or equal to"
        " 64.");

    localUserInfo = ZegoUserInfo(userID, userName);

    if (!userDic.containsKey(userID)) {
      userList.add(localUserInfo);
      userDic[userID] = localUserInfo;
    }
  }

  @override
  Future<RequestResult> getToken(
      String userID, int effectiveTimeInSeconds) async {
    if (!ZegoServiceManager.shared.isSDKInit) {
      assert(false, "The SDK must be initialised first.");
      return Failure(ZegoError.notInit);
    }

    if (localUserInfo.isEmpty()) {
      assert(false, "Must be logged in first.");
      return Failure(ZegoError.notLogin);
    }

    if (effectiveTimeInSeconds < 0 || userID.isEmpty) {
      assert(false, "Must be logged in first.");
      return Failure(ZegoError.paramInvalid);
    }

    var command = ZegoTokenCommand(userID, effectiveTimeInSeconds);

    var result = await command.execute();
    if (result.isSuccess) {
      var dict = result.success as Map<String, dynamic>;
      log('[user service] get token, $dict');
      return Success(dict['token'] as String);
    }
    return Failure(ZegoError.failed);
  }

  @override
  ZegoUserInfo getUserInfoByID(String userID) {
    return userDic[userID] ?? ZegoUserInfo.empty();
  }

  @override
  void onNetworkQuality(String userID, ZegoStreamQualityLevel upstreamQuality,
      ZegoStreamQualityLevel downstreamQuality) {
    delegate?.onNetworkQuality(userID, upstreamQuality);
  }

  @override
  void onRemoteCameraStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    final userID = getUserIDFromStreamID(streamID);
    if (userID.isEmpty) {
      return;
    }
    if (ZegoRemoteDeviceState.Open != state &&
        ZegoRemoteDeviceState.Disable != state) {
      return;
    }

    var remoteUser = getUserInfoByID(userID);
    if (remoteUser.isEmpty()) {
      return;
    }
    remoteUser.camera = ZegoRemoteDeviceState.Open == state;
    delegate?.onUserInfoUpdate(remoteUser);
  }

  @override
  void onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    final userID = getUserIDFromStreamID(streamID);
    if (userID.isEmpty) {
      return;
    }
    if (ZegoRemoteDeviceState.Open != state &&
        ZegoRemoteDeviceState.Mute != state) {
      return;
    }

    var remoteUser = getUserInfoByID(userID);
    if (remoteUser.isEmpty()) {
      return;
    }
    remoteUser.mic = ZegoRemoteDeviceState.Open == state;
    delegate?.onUserInfoUpdate(remoteUser);
  }

  @override
  void onRoomUserUpdate(
      String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {
    for (var user in userList) {
      if (ZegoUpdateType.Add == updateType) {
        if (!userDic.containsKey(user.userID)) {
          var userInfo = ZegoUserInfo(user.userID, user.userName);
          userDic[user.userID] = userInfo;
          this.userList.add(userInfo);
        }
      } else {
        userDic.remove(user.userID);
        this.userList.removeWhere((element) => element.userID == user.userID);
      }
    }
  }
}
