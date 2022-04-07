// Project imports:
import '../../../zegocall/core/model/zego_user_info.dart';
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoCallCommand extends ZegoCommand {
  ZegoCallCommand(String callID, ZegoUserInfo caller,
      List<ZegoUserInfo> callees, ZegoCallType callType)
      : super(apiStartCall) {
    parameters["call_id"] = callID;
    parameters["caller"] = caller;
    parameters["callee"] = callees;
    parameters["type"] = callType;
  }
}
