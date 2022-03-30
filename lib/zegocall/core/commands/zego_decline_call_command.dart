// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoDeclineCallCommand extends ZegoCommand {
  ZegoDeclineCallCommand(String path, Map<String, dynamic> parameters)
      : super(apiDeclineCall, parameters) {
    parameters["id"] = "";
    parameters["call_id"] = "";
    parameters["caller_id"] = "";
    parameters["type"] = ZegoDeclineType.kZegoDeclineTypeDecline;
  }
}
