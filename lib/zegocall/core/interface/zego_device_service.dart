// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import '../delegate/zego_device_service_delegate.dart';

abstract class IZegoDeviceService extends ChangeNotifier {
  bool noiseSlimming = true; // sdk default value
  bool echoCancellation = true; // sdk default value
  bool volumeAdjustment = true; // sdk default value
  bool isMirroring = false;
  bool isFrontCamera = true;
  ZegoDeviceServiceDelegate? delegate;

  bool get getNoiseSlimming => noiseSlimming;

  void setNoiseSlimming(bool noiseSlimming) =>
      this.noiseSlimming = noiseSlimming;

  bool get getEchoCancellation => echoCancellation;

  void setEchoCancellation(bool echoCancellation) =>
      this.echoCancellation = echoCancellation;

  bool get getVolumeAdjustment => volumeAdjustment;

  void setIsMirroring(bool isMirroring) => this.isMirroring = isMirroring;

  bool get getIsMirroring => isMirroring;

  bool get getIsFrontCamera => isFrontCamera;

  void setVolumeAdjustment(bool volumeAdjustment) =>
      this.volumeAdjustment = volumeAdjustment;

  ZegoDeviceServiceDelegate? get getDelegate => delegate;

  set setDelegate(ZegoDeviceServiceDelegate delegate) => delegate = delegate;

  Future<ZegoVideoResolution> getVideoResolution();

  void setVideoResolution(ZegoVideoResolution videoResolution);

  Future<ZegoAudioBitrate> getAudioBitrate();

  void setAudioBitrate(ZegoAudioBitrate bitrate);

  void enableCamera(bool enable);

  void muteMic(bool mute);

  Future<bool> isMicMuted();

  void useFrontCamera(bool enable, {ZegoPublishChannel? channel});

  void enableSpeaker(bool enable);

  Future<bool> isSpeakerEnabled();

  void setBestConfig();
}
