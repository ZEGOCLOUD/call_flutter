// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import './../../../zegocall/core/zego_call_defines.dart';
import './../delegate/zego_device_service_delegate.dart';
import 'zego_service.dart';

abstract class IZegoDeviceService extends ChangeNotifier with ZegoService {
  ZegoVideoResolution videoResolution = ZegoVideoResolution.p270;
  ZegoAudioBitrate audioBitrate = ZegoAudioBitrate.b48;
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

  void setVideoResolution(ZegoVideoResolution videoResolution);

  void setAudioBitrate(ZegoAudioBitrate bitrate);

  void enableCamera(bool enable);

  void enableMic(bool enable);

  void useFrontCamera(bool enable, {ZegoPublishChannel? channel});

  void enableSpeaker(bool enable);

  void setBestConfig();

  void resetDeviceConfig();
}
