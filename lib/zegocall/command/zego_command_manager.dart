// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/command/zego_request_protocol.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import '../request/zego_firebase_manager.dart';

class ZegoCommandManager extends ChangeNotifier {
  static var shared = ZegoCommandManager();

  ZegoRequestProtocol service = ZegoFireBaseManager();

  Future<ZegoError> execute(ZegoCommand command) async {
    return service.request(command.path, command.parameters);
  }
}
