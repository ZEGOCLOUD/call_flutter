// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../interface/zego_event_handler.dart';
import '../interface/zego_user_service.dart';
import '../interface_imp/zego_stream_service_impl.dart';
import '../manager/zego_service_manager.dart';
import '../model/zego_user_info.dart';

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
