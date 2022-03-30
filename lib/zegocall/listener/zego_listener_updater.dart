// Project imports:
import 'package:zego_call_flutter/zegocall/listener/zego_listener.dart';

mixin ZegoListenerUpdater {
  void receiveUpdate(String path, ZegoNotifyListenerParameter parameter);
}
