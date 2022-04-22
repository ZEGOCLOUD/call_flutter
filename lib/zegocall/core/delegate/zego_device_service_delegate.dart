// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

mixin ZegoDeviceServiceDelegate {
  /// Callback for the audio output route changed
  ///
  /// Description: this callback will be triggered when switching the audio output between speaker, receiver, and bluetooth headset.
  /// - Parameter audioRoute: the device type of audio output.
  void onAudioRouteChange(ZegoAudioRoute audioRoute);
}
