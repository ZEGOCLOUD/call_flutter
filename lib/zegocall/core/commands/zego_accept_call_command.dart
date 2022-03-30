// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoAcceptCallCommand extends ZegoCommand {
  ZegoAcceptCallCommand(String path, Map<String, dynamic> parameters)
      : super(apiAcceptCall, parameters) {
    parameters["id"] = "";
    parameters["call_id"] = "";
  }
}
