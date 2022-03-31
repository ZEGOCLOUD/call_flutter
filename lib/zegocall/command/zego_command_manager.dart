// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'zego_command.dart';
import 'zego_request_protocol.dart';
import './../core/zego_call_defines.dart';
import '../request/zego_firebase_manager.dart';

class ZegoCommandManager extends ChangeNotifier {
  static var shared = ZegoCommandManager();

  ZegoRequestProtocol service = ZegoFireBaseManager();

  Future<RequestResult> execute(ZegoCommand command) async {
    return service.request(command.path, command.parameters);
  }
}
