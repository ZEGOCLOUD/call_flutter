// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoLogoutCommand extends ZegoCommand {
  ZegoLogoutCommand(String path, Map<String, dynamic> parameters)
      : super(apiLogout, parameters);
}
