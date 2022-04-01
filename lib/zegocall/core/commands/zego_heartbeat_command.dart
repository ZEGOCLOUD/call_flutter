// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoHeartbeatCommand extends ZegoCommand {
  ZegoHeartbeatCommand(String userID, String callID) : super(apiCallHeartbeat) {
    parameters["id"] = userID;
    parameters["call_id"] = callID;
  }
}
