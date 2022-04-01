// Project imports:
import 'zego_listener.dart';

class ZegoListenerHandler {
  String uid;
  String path;
  ZegoNotifyListener listener;

  ZegoListenerHandler(this.path, this.uid, this.listener);
}
