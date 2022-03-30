// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoGetUserCommand extends ZegoCommand {
  ZegoGetUserCommand(String path, Map<String, dynamic> parameters)
      : super(apiGetUser, parameters) {
    parameters["id"] = "";
  }
}
