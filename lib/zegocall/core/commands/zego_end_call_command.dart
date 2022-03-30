// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoEndCallCommand extends ZegoCommand {
  ZegoEndCallCommand(String path, Map<String, dynamic> parameters)
      : super(apiEndCall, parameters) {
    parameters["id"] = "";
    parameters["call_id"] = "";
  }
}
