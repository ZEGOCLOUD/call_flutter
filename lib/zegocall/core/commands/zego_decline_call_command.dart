// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoDeclineCallCommand extends ZegoCommand {
  ZegoDeclineCallCommand(String callID, String callerID) :
        super(apiDeclineCall) {
    parameters["call_id"] = callID;
    parameters["caller_id"] = callerID;
  }
}
