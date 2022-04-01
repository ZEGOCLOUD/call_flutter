// Project imports:
import '../core/zego_call_defines.dart';
import 'zego_command_manager.dart';

class ZegoCommand {
  String path;
  RequestParameterType parameters = {};

  ZegoCommand(this.path);

  Future<RequestResult> execute() async {
    return ZegoCommandManager.shared.execute(this);
  }
}
