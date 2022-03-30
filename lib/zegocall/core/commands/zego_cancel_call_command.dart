// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoCancelCallCommand extends ZegoCommand {
  ZegoCancelCallCommand(String path, Map<String, dynamic> parameters)
      : super(apiCancelCall, parameters) {
    parameters["call_id"] = "";
    parameters["callee_id"] = "";
  }
}
