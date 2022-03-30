// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoCallCommand extends ZegoCommand {
  ZegoCallCommand(String path, Map<String, dynamic> parameters)
      : super(apiStartCall, parameters) {
    parameters["id"] = "";
    parameters["call_id"] = "";
    parameters["call_name"] = "";
    parameters["callee_ids"] = [""];
    parameters["type"] = ZegoCallType.kZegoCallTypeVoice;
  }
}
