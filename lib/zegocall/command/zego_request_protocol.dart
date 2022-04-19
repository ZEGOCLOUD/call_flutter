// Project imports:
import '../core/zego_call_defines.dart';

abstract class ZegoRequestProtocol {
  Future<RequestResult> request(String path, RequestParameterType parameters);
}
