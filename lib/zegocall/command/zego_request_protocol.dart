// Project imports:
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

abstract class ZegoRequestProtocol {
  Future<ZegoError> request(String path, Map<String, dynamic> parameters);
}
