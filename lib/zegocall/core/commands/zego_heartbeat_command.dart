// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoHeartbeatCommand extends ZegoCommand {
  ZegoHeartbeatCommand(String path, Map<String, dynamic> parameters)
      : super(apiCallHeartbeat, parameters) {
    parameters["id"] = "";
    parameters["call_id"] = "";
  }
}
