// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoHeartbeatCommand extends ZegoCommand {
  ZegoHeartbeatCommand() : super(apiCallHeartbeat) {
    parameters["id"] = "";
    parameters["call_id"] = "";
  }
}
