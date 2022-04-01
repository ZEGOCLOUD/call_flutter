// Project imports:
import './../../command/zego_command.dart';
import './../../core/zego_call_defines.dart';

class ZegoTokenCommand extends ZegoCommand {
  ZegoTokenCommand(String userID) : super(apiGetToken) {
    parameters["id"] = userID;
    // 24h
    var effectiveTimeInSeconds = 24 * 3600;
    parameters["effective_time"] = effectiveTimeInSeconds;
  }
}
