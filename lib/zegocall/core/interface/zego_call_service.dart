// Project imports:
import 'package:flutter/cupertino.dart';
import 'package:zego_call_flutter/zegocall/core/delegate/zego_call_service_delegate.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_call_info.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

abstract class IZegoCallService extends ChangeNotifier {
  ZegoCallInfo callInfo = ZegoCallInfo.empty();
  ZegoCallServiceDelegate? delegate;
  LocalUserStatus status = LocalUserStatus.free;


  Future<int> callUser(String userID, String token, ZegoCallType type);

  Future<int> cancelCall(String userID);

  Future<int> acceptCall(String token);

  Future<int> declineCall(String userID, ZegoDeclineType type);

  Future<int> endCall();
}
