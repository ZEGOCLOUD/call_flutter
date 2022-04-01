// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoAcceptCallCommand extends ZegoCommand {
  ZegoAcceptCallCommand(String userID, String callID) : super(apiAcceptCall) {
    parameters["id"] = userID;
    parameters["call_id"] = callID;
  }
}
