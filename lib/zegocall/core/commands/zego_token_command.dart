// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoTokenCommand extends ZegoCommand {
  ZegoTokenCommand() : super(apiGetToken) {
    parameters["id"] = "";
    parameters["effective_time"] = "";
  }
}
