// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoTokenCommand extends ZegoCommand {
  ZegoTokenCommand(String userID, int effectiveTimeInSeconds) : super(apiGetToken) {
    parameters["id"] = userID;
    parameters["effective_time"] = effectiveTimeInSeconds;
  }
}
