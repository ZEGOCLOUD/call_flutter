// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoUserListCommand extends ZegoCommand {
  ZegoUserListCommand(String path, Map<String, dynamic> parameters)
      : super(apiGetUsers, parameters) {
    parameters["id"] = "";
    parameters["from"] = "";
    parameters["count"] = 100;
  }
}
