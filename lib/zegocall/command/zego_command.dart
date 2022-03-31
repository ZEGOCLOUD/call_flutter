// Project imports:
import 'zego_command_manager.dart';
import '../core/zego_call_defines.dart';

class ZegoCommand {
  String path;
  RequestParameterType parameters = {};

  ZegoCommand(this.path);

  Future<RequestResult> execute() async {
    return ZegoCommandManager.shared.execute(this);
  }
}
