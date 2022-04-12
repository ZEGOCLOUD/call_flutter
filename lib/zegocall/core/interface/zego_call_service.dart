// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import './../delegate/zego_call_service_delegate.dart';
import './../model/zego_call_info.dart';
import './../model/zego_user_info.dart';
import './../zego_call_defines.dart';
import 'zego_service.dart';

typedef CommandCallback = void Function(int);

abstract class IZegoCallService extends ChangeNotifier with ZegoService {
  ZegoCallInfo callInfo = ZegoCallInfo.empty();
  LocalUserStatus status = LocalUserStatus.free;

  ZegoCallServiceDelegate? delegate;

  ZegoError callUser(ZegoUserInfo callee, String token, ZegoCallType type,
      CommandCallback callback);

  Future<int> cancelCall();

  ZegoError acceptCall(String token, CommandCallback callback);

  Future<int> declineCall();

  Future<int> endCall();
}
