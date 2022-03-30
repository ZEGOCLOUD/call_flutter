import 'package:flutter/cupertino.dart';
import 'package:zego_call_flutter/zegocall/core/delegate/zego_stream_service_delegate.dart';

abstract class IZegoStreamService extends ChangeNotifier {
  ZegoStreamServiceDelegate? delegate;

  void startPlaying(String userID, int playingViewID);

  //  stream state notifier
  void addStreamStateNotifier(String userID, ValueChanged<bool> notifier);

  void removeStreamStateNotifier(String userID);
}
