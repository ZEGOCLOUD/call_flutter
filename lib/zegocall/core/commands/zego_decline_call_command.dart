// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoDeclineCallCommand extends ZegoCommand {
  ZegoDeclineCallCommand(
      String userID, String callID, String callerID, ZegoDeclineType type)
      : super(apiDeclineCall) {
    parameters["id"] = userID;
    parameters["call_id"] = callID;
    parameters["caller_id"] = callerID;
    parameters["type"] = type.id;
  }
}
