// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../model/zego_user_info.dart';
import './../delegate/zego_call_service_delegate.dart';
import './../model/zego_call_info.dart';
import './../zego_call_defines.dart';

abstract class IZegoCallService extends ChangeNotifier {
  ZegoCallInfo callInfo = ZegoCallInfo.empty();
  ZegoCallServiceDelegate? delegate;
  LocalUserStatus status = LocalUserStatus.free;

  Future<int> callUser(ZegoUserInfo user, String token, ZegoCallType type);

  Future<int> cancelCall(String userID);

  Future<int> acceptCall(String token);

  Future<int> declineCall(String userID, ZegoDeclineType type);

  Future<int> endCall();
}
