// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../delegate/zego_stream_service_delegate.dart';
import 'zego_service.dart';

abstract class IZegoStreamService extends ChangeNotifier with ZegoService {
  ZegoStreamServiceDelegate? delegate;

  void startPreview(int viewID);

  void stopPreview();

  /// Start playing streams
  ///
  /// Description: this can be used to play audio or video streams.
  ///
  /// Call this method at: after joining a room
  ///
  /// - Parameter userID: the ID of the user you are connecting
  /// - Parameter viewID: refers to the view id of created by EXPRESS SDK
  void startPlaying(String userID, {int viewID = -1});

  /// Stop playing streams
  ///
  /// Description: this can be used to stop playing audio or video streams.
  ///
  /// Call this method at: after joining a room
  ///
  /// - Parameter userID:  the ID of the user you are connecting
  void stopPlaying(String userID);

  ///  stream state notifier
  ValueNotifier<bool> getCameraStateNotifier(String userID);

  /// notifies the stream service, when the device service changes the local camera status
  void onLocalCameraEnabled(bool enabled);
}
