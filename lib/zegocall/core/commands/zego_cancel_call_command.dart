// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoCancelCallCommand extends ZegoCommand {
  ZegoCancelCallCommand() : super(apiCancelCall) {
    parameters["call_id"] = "";
    parameters["callee_id"] = "";
  }
}
