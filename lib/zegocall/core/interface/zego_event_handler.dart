// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

mixin ZegoEventHandler {
  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {}

  void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {}

  void onRoomUserUpdate(
      String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {}

  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond) {}

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {}

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {}

  void onNetworkQuality(String userID, ZegoStreamQualityLevel upstreamQuality,
      ZegoStreamQualityLevel downstreamQuality) {}

  void onAudioRouteChange(ZegoAudioRoute audioRoute) {}

  void onRemoteCameraStateUpdate(
      String streamID, ZegoRemoteDeviceState state) {}

  void onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {}

  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) {}

  void onApiCalledResult(int errorCode, String funcName, String info) {}
}
