// Project imports:
import 'package:zego_call_flutter/zegocall/listener/zego_listener.dart';

class ZegoListenerHandler {
  String uid;
  String path;
  ZegoNotifyListener listener;

  ZegoListenerHandler(this.path, this.uid, this.listener);
}
