// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoUserListCommand extends ZegoCommand {
  ZegoUserListCommand() : super(apiGetUsers) {
    parameters["id"] = "";
    parameters["from"] = "";
    parameters["count"] = 100;
  }
}
