// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoAcceptCallCommand extends ZegoCommand {
  ZegoAcceptCallCommand() : super(apiAcceptCall) {
    parameters["id"] = "";
    parameters["call_id"] = "";
  }
}
