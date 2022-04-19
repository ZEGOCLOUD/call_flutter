// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import '../../../core/manager/zego_call_manager.dart';
import './../../styles.dart';
import './../../../../zegocall/core/zego_call_defines.dart';
import 'calling_bottom_toolbar_button.dart';

class OnlineBottomToolBar extends StatefulWidget {
  final ZegoCallType callType;

  const OnlineBottomToolBar({required this.callType, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OnlineBottomToolBarState();
  }
}

class OnlineBottomToolBarState extends State<OnlineBottomToolBar> {
  bool isMicEnabled = true;
  bool isCameraEnabled = true;
  bool isSpeakerEnabled = true;

  bool isFrontCameraUsed = true;

  String audioIconURL = "";

  @override
  void initState() {
    var userService = ZegoServiceManager.shared.userService;
    var deviceService = ZegoServiceManager.shared.deviceService;

    isMicEnabled = userService.localUserInfo.mic;
    isCameraEnabled = userService.localUserInfo.camera;
    isSpeakerEnabled = deviceService.isSpeakerEnabled;
    isFrontCameraUsed = deviceService.isFrontCamera;

    audioIconURL = getAudioRouteIconURLBySpeaker(
        ZegoServiceManager.shared.deviceService.isSpeakerEnabled);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ZegoCallType.kZegoCallTypeVideo == widget.callType
          ? EdgeInsets.only(left: 39.w, right: 39.w)
          : EdgeInsets.only(left: 88.w, right: 88.w),
      height: 120.h,
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buttons()),
      ),
    );
  }

  List<Widget> buttons() {
    if (ZegoCallType.kZegoCallTypeVideo == widget.callType) {
      return [
        cameraButton(),
        microphoneButton(),
        endButton(),
        cameraSwitchButton(),
        audioRouteButton()
      ];
    }

    return [microphoneButton(), endButton(), audioRouteButton()];
  }

  double iconWidth() {
    return ZegoCallType.kZegoCallTypeVideo == widget.callType ? 94.w : 120.w;
  }

  Widget cameraButton() {
    return CallingCalleeBottomToolBarButton(
      iconWidth: iconWidth(),
      iconHeight: 120.h,
      iconURL: isCameraEnabled
          ? StyleIconUrls.toolbarBottomCameraOpen
          : StyleIconUrls.toolbarBottomCameraClosed,
      onTap: () {
        setState(() {
          isCameraEnabled = !isCameraEnabled;
        });
        ZegoServiceManager.shared.deviceService.enableCamera(isCameraEnabled);

        var userService = ZegoServiceManager.shared.userService;
        userService.localUserInfo.camera = isCameraEnabled;
        ZegoServiceManager.shared.userService.delegate
            ?.onUserInfoUpdate(userService.localUserInfo);
      },
    );
  }

  Widget microphoneButton() {
    return CallingCalleeBottomToolBarButton(
      iconWidth: iconWidth(),
      iconHeight: 120.h,
      iconURL: isMicEnabled
          ? StyleIconUrls.toolbarBottomMicOpen
          : StyleIconUrls.toolbarBottomMicClosed,
      onTap: () async {
        setState(() {
          isMicEnabled = !isMicEnabled;
        });
        ZegoServiceManager.shared.deviceService.enableMic(isMicEnabled);

        var userService = ZegoServiceManager.shared.userService;
        userService.localUserInfo.mic = isMicEnabled;
        ZegoServiceManager.shared.userService.delegate
            ?.onUserInfoUpdate(userService.localUserInfo);
      },
    );
  }

  Widget endButton() {
    return CallingCalleeBottomToolBarButton(
      iconWidth: 120.w,
      iconHeight: 120.h,
      iconURL: StyleIconUrls.toolbarBottomEnd,
      onTap: () {
        ZegoCallManager.shared.endCall();
      },
    );
  }

  Widget cameraSwitchButton() {
    return CallingCalleeBottomToolBarButton(
      iconWidth: iconWidth(),
      iconHeight: 120.h,
      iconURL: StyleIconUrls.toolbarBottomSwitchCamera,
      onTap: () {
        setState(() {
          isFrontCameraUsed = !isFrontCameraUsed;
        });
        ZegoServiceManager.shared.deviceService
            .useFrontCamera(isFrontCameraUsed);
      },
    );
  }

  Widget audioRouteButton() {
    return ValueListenableBuilder<ZegoAudioRoute>(
      valueListenable:
          ZegoServiceManager.shared.deviceService.audioRouteNotifier,
      builder: (context, audioRoute, _) {
        return getAudioRouteButtonByRoute(audioRoute);
      },
    );
  }

  Widget getAudioRouteButtonByRoute(ZegoAudioRoute audioRoute) {
    if (ZegoAudioRoute.Headphone == audioRoute ||
        ZegoAudioRoute.Bluetooth == audioRoute) {
      audioIconURL = StyleIconUrls.toolbarBottomBlueTooth;
    } else {
      audioIconURL = getAudioRouteIconURLBySpeaker(isSpeakerEnabled);
    }
    return CallingCalleeBottomToolBarButton(
      iconWidth: iconWidth(),
      iconHeight: 120.h,
      iconURL: audioIconURL,
      onTap: onAudioRouteButtonTap,
    );
  }

  String getAudioRouteIconURLBySpeaker(bool isSpeakerEnabled) {
    return isSpeakerEnabled
        ? StyleIconUrls.toolbarBottomSpeakerOpen
        : StyleIconUrls.toolbarBottomSpeakerClosed;
  }

  void onAudioRouteButtonTap() {
    var audioRoute =
        ZegoServiceManager.shared.deviceService.audioRouteNotifier.value;
    if (ZegoAudioRoute.Headphone == audioRoute ||
        ZegoAudioRoute.Bluetooth == audioRoute) {
      return; //  not support switch
    }

    setState(() {
      isSpeakerEnabled = !isSpeakerEnabled;
      audioIconURL = getAudioRouteIconURLBySpeaker(isSpeakerEnabled);
    });
    ZegoServiceManager.shared.deviceService.enableSpeaker(isSpeakerEnabled);
  }
}
