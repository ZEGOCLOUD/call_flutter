// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoTokenCommand extends ZegoCommand {
  ZegoTokenCommand(String path, Map<String, dynamic> parameters)
      : super(apiGetToken, parameters) {
    parameters["id"] = "";
    parameters["effective_time"] = "";
  }
}
