// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoCallCommand extends ZegoCommand {
  ZegoCallCommand() : super(apiStartCall) {
    parameters["id"] = "";
    parameters["call_id"] = "";
    parameters["call_name"] = "";
    parameters["callee_ids"] = [""];
    parameters["type"] = ZegoCallType.kZegoCallTypeVoice;
  }
}
