// Project imports:
import '../../command/zego_command.dart';
import '../../core/zego_call_defines.dart';

class ZegoEndCallCommand extends ZegoCommand {
  ZegoEndCallCommand(String userID, String callID) : super(apiEndCall) {
    parameters["id"] = userID;
    parameters["call_id"] = callID;
  }
}
