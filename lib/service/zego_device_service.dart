import 'dart:io';
import 'package:flutter/cupertino.dart';
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
  bool noiseSlimming = true; // sdk default value
  bool echoCancellation = true; // sdk default value
  bool volumeAdjustment = true; // sdk default value
  bool isMirroring = false;
  late ZegoDeviceServiceDelegate delegate;

  String getResolutionString(ZegoVideoResolution resolution) {
    switch (resolution) {
      case ZegoVideoResolution.v1080P:
        return "1920x1080";
      case ZegoVideoResolution.v720P:
        return "1080x720";
      case ZegoVideoResolution.v540P:
        return "960x540";
      case ZegoVideoResolution.v360P:
        return "640x360";
      case ZegoVideoResolution.v270P:
        return "480x270";
      case ZegoVideoResolution.v180P:
        return "320x180";
    }
  }

  String getBitrateString(ZegoAudioBitrate bitrate) {
    String bitrateString = "";
    switch (bitrate) {
      case ZegoAudioBitrate.b16:
        bitrateString = "16";
        break;
      case ZegoAudioBitrate.b48:
        bitrateString = "48";
        break;
      case ZegoAudioBitrate.b56:
        bitrateString = "56";
        break;
      case ZegoAudioBitrate.b96:
        bitrateString = "96";
        break;
      case ZegoAudioBitrate.b128:
        bitrateString = "128";
        break;
      default:
        bitrateString = "48";
        break;
    }

    return bitrateString + "kbps";
  }

  int getAudioBitrateValue(ZegoAudioBitrate bitrate) {
    switch (bitrate) {
      case ZegoAudioBitrate.b16:
        return 16;
      case ZegoAudioBitrate.b48:
        return 48;
      case ZegoAudioBitrate.b56:
        return 56;
      case ZegoAudioBitrate.b96:
        return 96;
      case ZegoAudioBitrate.b128:
        return 128;
      default:
        return 48;
    }
  }

  bool get getNoiseSlimming => noiseSlimming;

  void setNoiseSlimming(bool noiseSlimming) =>
      this.noiseSlimming = noiseSlimming;

  bool get getEchoCancellation => echoCancellation;

  void setEchoCancellation(bool echoCancellation) =>
      this.echoCancellation = echoCancellation;

  bool get getVolumeAdjustment => volumeAdjustment;

  void setIsMirroring(bool isMirroring) => this.isMirroring = isMirroring;

  bool get getIsMirroring => isMirroring;

  void setVolumeAdjustment(bool volumeAdjustment) =>
      this.volumeAdjustment = volumeAdjustment;

  ZegoDeviceServiceDelegate get getDelegate => delegate;

  set setDelegate(ZegoDeviceServiceDelegate delegate) => delegate = delegate;

  Future<ZegoVideoResolution> getVideoResolution();

  void setVideoResolution(ZegoVideoResolution videoResolution);

  Future<ZegoAudioBitrate> getAudioBitrate();

  void setAudioBitrate(ZegoAudioBitrate bitrate);

  void enableCamera(bool enable);

  void muteMic(bool mute);

  void useFrontCamera(bool enable, {ZegoPublishChannel? channel});

  void enableSpeaker(bool enable);

  void enableCallKit(bool enable);
}

class ZegoDeviceService extends ChangeNotifier with IZegoDeviceService {
  @override
  void enableCamera(bool enable) {
    ZegoExpressEngine.instance.enableCamera(enable);
  }

  @override
  void muteMic(bool mute) {
    ZegoExpressEngine.instance.muteMicrophone(mute);
  }

  Future<bool> isMicMuted() async {
    return ZegoExpressEngine.instance.isMicrophoneMuted();
  }

  @override
  void useFrontCamera(bool enable, {ZegoPublishChannel? channel}) {
    ZegoExpressEngine.instance.useFrontCamera(enable);
  }

  @override
  void enableSpeaker(bool enable) {
    ZegoExpressEngine.instance.muteSpeaker(!enable);
  }

  Future<bool> isSpeakerEnabled() async {
    return !await ZegoExpressEngine.instance.isSpeakerMuted();
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

  @override
  void setAudioBitrate(ZegoAudioBitrate bitrate) async {
    var config = await ZegoExpressEngine.instance.getAudioConfig();
    config.bitrate = getAudioBitrateValue(bitrate);
    ZegoExpressEngine.instance.setAudioConfig(config);
  }

  @override
  Future<ZegoAudioBitrate> getAudioBitrate() async {
    var config = await ZegoExpressEngine.instance.getAudioConfig();
    if (config.bitrate < 48) {
      return ZegoAudioBitrate.b16;
    } else if (config.bitrate < 56) {
      return ZegoAudioBitrate.b48;
    } else if (config.bitrate < 96) {
      return ZegoAudioBitrate.b56;
    } else if (config.bitrate < 128) {
      return ZegoAudioBitrate.b96;
    } else {
      return ZegoAudioBitrate.b128;
    }
  }

  @override
  void setVideoResolution(ZegoVideoResolution videoResolution) async {
    var config = await ZegoExpressEngine.instance.getVideoConfig();
    switch (videoResolution) {
      case ZegoVideoResolution.v1080P:
        config.captureWidth = 1920;
        config.captureHeight = 1080;
        config.encodeWidth = 1920;
        config.encodeHeight = 1080;
        break;
      case ZegoVideoResolution.v720P:
        config.captureWidth = 1080;
        config.captureHeight = 720;
        config.encodeWidth = 1080;
        config.encodeHeight = 720;
        break;
      case ZegoVideoResolution.v540P:
        config.captureWidth = 960;
        config.captureHeight = 540;
        config.encodeWidth = 960;
        config.encodeHeight = 540;
        break;
      case ZegoVideoResolution.v360P:
        config.captureWidth = 640;
        config.captureHeight = 360;
        config.encodeWidth = 640;
        config.encodeHeight = 360;
        break;
      case ZegoVideoResolution.v270P:
        config.captureWidth = 480;
        config.captureHeight = 270;
        config.encodeWidth = 480;
        config.encodeHeight = 270;
        break;
      case ZegoVideoResolution.v180P:
        config.captureWidth = 320;
        config.captureHeight = 180;
        config.encodeWidth = 320;
        config.encodeHeight = 180;
        break;
    }
    ZegoExpressEngine.instance.setVideoConfig(config);
  }

  @override
  Future<ZegoVideoResolution> getVideoResolution() async {
    var config = await ZegoExpressEngine.instance.getVideoConfig();
    if (config.captureHeight < 270) {
      return ZegoVideoResolution.v180P;
    } else if (config.captureHeight < 360) {
      return ZegoVideoResolution.v270P;
    } else if (config.captureHeight < 540) {
      return ZegoVideoResolution.v360P;
    } else if (config.captureHeight < 720) {
      return ZegoVideoResolution.v540P;
    } else if (config.captureHeight < 1080) {
      return ZegoVideoResolution.v720P;
    } else {
      return ZegoVideoResolution.v1080P;
    }
  }

  @override
  void setNoiseSlimming(bool noiseSlimming) async {
    super.setNoiseSlimming(noiseSlimming);

    ZegoExpressEngine.instance.enableANS(noiseSlimming);
  }

  @override
  void setEchoCancellation(bool echoCancellation) async {
    super.setEchoCancellation(echoCancellation);

    ZegoExpressEngine.instance.enableAEC(echoCancellation);
  }

  @override
  void setVolumeAdjustment(bool volumeAdjustment) async {
    super.setVolumeAdjustment(volumeAdjustment);

    ZegoExpressEngine.instance.enableAGC(volumeAdjustment);
  }

  @override
  void setIsMirroring(bool isMirroring) async {
    super.setIsMirroring(isMirroring);

    ZegoExpressEngine.instance.setVideoMirrorMode(isMirroring
        ? ZegoVideoMirrorMode.BothMirror
        : ZegoVideoMirrorMode.NoMirror);
  }
}
