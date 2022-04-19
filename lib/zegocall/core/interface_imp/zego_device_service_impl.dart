// Dart imports:
import 'dart:io';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import '../interface/zego_device_service.dart';
import '../interface/zego_event_handler.dart';
import '../manager/zego_service_manager.dart';
import '../zego_call_defines.dart';

class ZegoDeviceServiceImpl extends IZegoDeviceService with ZegoEventHandler {
  @override
  void init() {
    ZegoServiceManager.shared.addExpressEventHandler(this);

    ZegoExpressEngine.instance.isMicrophoneMuted().then((value) {
      isMicEnabled = !value;
    });
    ZegoExpressEngine.instance.isSpeakerMuted().then((value) {
      isSpeakerEnabled = !value;
    });

    ZegoExpressEngine.instance.getAudioConfig().then((config) {
      if (config.bitrate < 48) {
        audioBitrate = ZegoAudioBitrate.b16;
      } else if (config.bitrate < 56) {
        audioBitrate = ZegoAudioBitrate.b48;
      } else if (config.bitrate < 96) {
        audioBitrate = ZegoAudioBitrate.b56;
      } else if (config.bitrate < 128) {
        audioBitrate = ZegoAudioBitrate.b96;
      } else {
        audioBitrate = ZegoAudioBitrate.b128;
      }
    });

    ZegoExpressEngine.instance.getVideoConfig().then((config) {
      if (config.captureHeight < 270) {
        videoResolution = ZegoVideoResolution.p180;
      } else if (config.captureHeight < 360) {
        videoResolution = ZegoVideoResolution.p270;
      } else if (config.captureHeight < 540) {
        videoResolution = ZegoVideoResolution.p360;
      } else if (config.captureHeight < 720) {
        videoResolution = ZegoVideoResolution.p540;
      } else if (config.captureHeight < 1080) {
        videoResolution = ZegoVideoResolution.p720;
      } else {
        videoResolution = ZegoVideoResolution.p1080;
      }
    });
  }

  @override
  void enableCamera(bool enable) {
    ZegoExpressEngine.instance.enableCamera(enable).then((value) {
      ZegoServiceManager.shared.streamService.onLocalCameraEnabled(enable);
    });
  }

  @override
  void enableMic(bool enable) {
    ZegoExpressEngine.instance.muteMicrophone(!enable);
  }

  @override
  void useFrontCamera(bool enable, {ZegoPublishChannel? channel}) {
    super.isFrontCamera = enable;

    ZegoExpressEngine.instance.useFrontCamera(enable);
  }

  @override
  void enableSpeaker(bool enable) {
    //  switch to phone receiver if disable, instead of mute speaker
    // ZegoExpressEngine.instance.muteSpeaker(!enable);
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(enable);
  }

  @override
  void setAudioBitrate(ZegoAudioBitrate bitrate) async {
    var config = await ZegoExpressEngine.instance.getAudioConfig();
    config.bitrate = getAudioBitrateValue(bitrate);
    ZegoExpressEngine.instance.setAudioConfig(config);
  }

  @override
  void setVideoResolution(ZegoVideoResolution videoResolution) async {
    this.videoResolution = videoResolution;

    var config = await ZegoExpressEngine.instance.getVideoConfig();
    switch (videoResolution) {
      case ZegoVideoResolution.p1080:
        config.captureWidth = 1920;
        config.captureHeight = 1080;
        config.encodeWidth = 1920;
        config.encodeHeight = 1080;
        break;
      case ZegoVideoResolution.p720:
        config.captureWidth = 1080;
        config.captureHeight = 720;
        config.encodeWidth = 1080;
        config.encodeHeight = 720;
        break;
      case ZegoVideoResolution.p540:
        config.captureWidth = 960;
        config.captureHeight = 540;
        config.encodeWidth = 960;
        config.encodeHeight = 540;
        break;
      case ZegoVideoResolution.p360:
        config.captureWidth = 640;
        config.captureHeight = 360;
        config.encodeWidth = 640;
        config.encodeHeight = 360;
        break;
      case ZegoVideoResolution.p270:
        config.captureWidth = 480;
        config.captureHeight = 270;
        config.encodeWidth = 480;
        config.encodeHeight = 270;
        break;
      case ZegoVideoResolution.p180:
        config.captureWidth = 320;
        config.captureHeight = 180;
        config.encodeWidth = 320;
        config.encodeHeight = 180;
        break;
    }
    ZegoExpressEngine.instance.setVideoConfig(config);
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

  @override
  void setBestConfig() {
    ZegoExpressEngine.instance.enableHardwareEncoder(true);
    ZegoExpressEngine.instance.enableHardwareDecoder(true);
    ZegoExpressEngine.instance
        .setCapturePipelineScaleMode(ZegoCapturePipelineScaleMode.Post);
    ZegoExpressEngine.instance.setMinVideoBitrateForTrafficControl(
        120, ZegoTrafficControlMinVideoBitrateMode.UltraLowFPS);
    ZegoExpressEngine.instance.setTrafficControlFocusOn(
        ZegoTrafficControlFocusOnMode.ZegoTrafficControlFounsOnRemote);
    ZegoExpressEngine.instance.enableANS(false);

    Map<String, String> advancedConfig = {"room_retry_time": "60"};
    if (Platform.isIOS) {
      //  only for iOS
      advancedConfig["support_apple_callkit"] = "true";
    }
    var config = ZegoEngineConfig();
    config.advancedConfig = advancedConfig;
    ZegoExpressEngine.setEngineConfig(config);
  }

  @override
  void onAudioRouteChange(ZegoAudioRoute audioRoute) {
    super.audioRouteNotifier.value = audioRoute;

    delegate?.onAudioRouteChange(audioRoute);
  }

  @override
  void resetDeviceConfig() {
    // setVideoResolution(ZegoVideoResolution.p720);
    // setAudioBitrate(ZegoAudioBitrate.b48);
    setNoiseSlimming(true);
    setEchoCancellation(true);
    setVolumeAdjustment(true);
    setIsMirroring(false);
    useFrontCamera(true);

    super.audioRouteNotifier.value = ZegoAudioRoute.Speaker;
  }
}

String getResolutionString(ZegoVideoResolution resolution) {
  switch (resolution) {
    case ZegoVideoResolution.p1080:
      return "1920x1080";
    case ZegoVideoResolution.p720:
      return "1080x720";
    case ZegoVideoResolution.p540:
      return "960x540";
    case ZegoVideoResolution.p360:
      return "640x360";
    case ZegoVideoResolution.p270:
      return "480x270";
    case ZegoVideoResolution.p180:
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
