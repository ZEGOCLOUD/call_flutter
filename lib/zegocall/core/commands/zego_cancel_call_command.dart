// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoCancelCallCommand extends ZegoCommand {
  ZegoCancelCallCommand(String userID, String callID, String calleeID)
      : super(apiCancelCall) {
    parameters["id"] = userID;
    parameters["call_id"] = callID;
    parameters["callee_id"] = callID;
  }
}
