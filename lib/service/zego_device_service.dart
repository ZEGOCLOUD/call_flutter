import 'dart:io';
import 'package:zego_express_engine/zego_express_engine.dart';

enum ZegoDeviceType {
  zegoNoiseSuppression,
  zegoEchoCancellation,
  zegoVolumeAdjustment,
}

enum ZegoVideoResolution {
  v1080P,
  v720P,
  v540P,
  v360P,
  v270P,
  v180P,
}

enum ZegoAudioBitrate {
  b16,
  b48,
  b56,
  b96,
  b128,
}

mixin ZegoDeviceServiceDelegate {
  void onAudioRouteChange(ZegoAudioRoute audioRoute);
}

abstract class IZegoDeviceService {
  late ZegoVideoResolution videoResolution;
  late ZegoAudioBitrate bitrate;
  late bool noiseSlimming;
  late bool echoCancellation;
  late bool volumeAdjustment;
  late ZegoDeviceServiceDelegate delegate;

  ZegoVideoResolution get getVideoResolution => videoResolution;

  set setVideoResolution(ZegoVideoResolution videoResolution) =>
      videoResolution = videoResolution;

  ZegoAudioBitrate get getBitrate => bitrate;

  set setBitrate(ZegoAudioBitrate bitrate) => bitrate = bitrate;

  bool get getNoiseSlimming => noiseSlimming;

  set setNoiseSlimming(bool noiseSlimming) => noiseSlimming = noiseSlimming;

  bool get getEchoCancellation => echoCancellation;

  set setEchoCancellation(bool echoCancellation) =>
      echoCancellation = echoCancellation;

  bool get getVolumeAdjustment => volumeAdjustment;

  set setVolumeAdjustment(bool volumeAdjustment) =>
      volumeAdjustment = volumeAdjustment;

  ZegoDeviceServiceDelegate get getDelegate => delegate;

  set setDelegate(ZegoDeviceServiceDelegate delegate) => delegate = delegate;

  void enableCamera(bool enable);

  void muteMic(bool mute);

  void useFrontCamera(bool enable, {ZegoPublishChannel? channel});

  void enableSpeaker(bool enable);

  void enableCallKit(bool enable);
}

class ZegoDeviceService extends IZegoDeviceService {
  @override
  void enableCamera(bool enable) {
    ZegoExpressEngine.instance.enableCamera(enable);
  }

  @override
  void muteMic(bool mute) {
    ZegoExpressEngine.instance.muteMicrophone(mute);
  }

  @override
  void useFrontCamera(bool enable, {ZegoPublishChannel? channel}) {
    ZegoExpressEngine.instance.useFrontCamera(enable);
  }

  @override
  void enableSpeaker(bool enable) {
    ZegoExpressEngine.instance.muteSpeaker(!enable);
  }

  @override
  void enableCallKit(bool enable) {
    if (!Platform.isIOS) {
      return;
    }
    //  only for iOS
    var config = ZegoEngineConfig();
    var enableStr = enable ? "true" : "false";
    config.advancedConfig = {"support_apple_callkit": enableStr};
    ZegoExpressEngine.setEngineConfig(config);
  }
}
