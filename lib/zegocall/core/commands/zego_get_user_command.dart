// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoGetUserCommand extends ZegoCommand {
  ZegoGetUserCommand() : super(apiGetUser) {
    parameters["id"] = "";
  }
}
