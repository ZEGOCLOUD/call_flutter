// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command_manager.dart';

class ZegoCommand {
  String path;
  Map<String, dynamic> parameters = {};

  ZegoCommand(this.path, this.parameters);

  void execute() {
    ZegoCommandManager.shared.execute(this);
  }
}
