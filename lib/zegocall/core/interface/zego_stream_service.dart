// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import './../delegate/zego_stream_service_delegate.dart';
import 'zego_service.dart';

abstract class IZegoStreamService extends ChangeNotifier with ZegoService {
  ZegoStreamServiceDelegate? delegate;

  void startPreview(int viewID);
  void stopPreview();

  void startPlaying(String userID, {int viewID = -1});

  //  stream state notifier
  ValueNotifier<bool> getCameraStateNotifier(String userID);

  void onLocalCameraEnabled(bool enabled);
}
