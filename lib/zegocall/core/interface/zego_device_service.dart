// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../delegate/zego_device_service_delegate.dart';
import '../zego_call_defines.dart';
import 'zego_service.dart';

abstract class IZegoDeviceService extends ChangeNotifier with ZegoService {
  ZegoVideoResolution videoResolution = ZegoVideoResolution.p270;
  ZegoAudioBitrate audioBitrate = ZegoAudioBitrate.b32;
  bool isMicEnabled = true;
  bool isSpeakerEnabled = true;

  bool noiseSlimming = true; // sdk default value
  bool echoCancellation = true; // sdk default value
  bool volumeAdjustment = true; // sdk default value
  bool isMirroring = false;
  bool isFrontCamera = true;

  ValueNotifier<ZegoAudioRoute> audioRouteNotifier =
      ValueNotifier<ZegoAudioRoute>(ZegoAudioRoute.Speaker);

  ZegoDeviceServiceDelegate? delegate;

  /// Whether to enable or disable the noise suppression
  void setNoiseSlimming(bool noiseSlimming) =>
      this.noiseSlimming = noiseSlimming;

  bool get getNoiseSlimming => noiseSlimming;

  /// Whether to enable or disable the echo cancellation
  void setEchoCancellation(bool echoCancellation) =>
      this.echoCancellation = echoCancellation;

  bool get getEchoCancellation => echoCancellation;

  /// Whether to enable or disable the video mirroring
  void setIsMirroring(bool isMirroring) => this.isMirroring = isMirroring;

  bool get getIsMirroring => isMirroring;

  /// Whether to enable or disable the volume auto-adjustment
  void setVolumeAdjustment(bool volumeAdjustment) =>
      this.volumeAdjustment = volumeAdjustment;

  bool get getVolumeAdjustment => volumeAdjustment;

  /// The delegate instance of the device service.
  set setDelegate(ZegoDeviceServiceDelegate delegate) => delegate = delegate;

  ZegoDeviceServiceDelegate? get getDelegate => delegate;

  /// Video resolution
  void setVideoResolution(ZegoVideoResolution videoResolution);

  /// Audio bitrate
  void setAudioBitrate(ZegoAudioBitrate bitrate);

  /// Turns on/off the camera
  ///
  /// Description: This is used to control whether to start the camera acquisition. After the camera is turned off, video capture will not be performed. At this time, the publish stream will also have no video data.
  ///  Call this method at: After joining a room
  ///
  /// @param enable determines whether to turn on the camera, `true`: turn on camera, `false`: turn off camera.
  void enableCamera(bool enable);

  /// Mutes or unmutes the microphone
  ///
  /// Description: This is used to control whether to use the collected audio data. Mute (turn off the microphone) will use the muted data to replace the audio data collected by the device for streaming. At this time, the microphone device will still be occupied.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param mute determines whether to mute (disable) the microphone, `true`: mute (disable) microphone, `false`: enable microphone.
  void enableMic(bool enable);

  /// Use front-facing or rear camera
  ///
  /// Description: This can be used to set the camera, the SDK uses the front-facing camera by default.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param isFront determines whether to use the front-facing camera or the rear camera.  true: Use front-facing camera. false: Use rear camera.
  void useFrontCamera(bool enable, {ZegoPublishChannel? channel});

  bool get getIsFrontCamera => isFrontCamera;

  /// Use speaker or receiver
  ///
  /// Description: This can be used to set the speaker and receiver.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param enable determines whether to use the speaker or the receiver. true: use the speaker. false: use the receiver.
  void enableSpeaker(bool enable);

  /// Set optimal configuration
  void setBestConfig();

  /// Reset device configuration
  void resetDeviceConfig();
}
