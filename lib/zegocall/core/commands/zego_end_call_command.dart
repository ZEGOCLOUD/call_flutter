// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoEndCallCommand extends ZegoCommand {
  ZegoEndCallCommand(String path) : super(apiEndCall) {
    parameters["id"] = "";
    parameters["call_id"] = "";
  }
}
