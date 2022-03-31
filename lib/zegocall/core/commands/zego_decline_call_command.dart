// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoDeclineCallCommand extends ZegoCommand {
  ZegoDeclineCallCommand() : super(apiDeclineCall) {
    parameters["id"] = "";
    parameters["call_id"] = "";
    parameters["caller_id"] = "";
    parameters["type"] = ZegoDeclineType.kZegoDeclineTypeDecline;
  }
}
