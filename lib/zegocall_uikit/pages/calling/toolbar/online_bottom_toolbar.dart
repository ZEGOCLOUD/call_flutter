// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import '../../../core/manager/zego_call_manager.dart';
import './../../../../utils/styles.dart';
import 'calling_bottom_toolbar_button.dart';

class OnlineVoiceBottomToolBar extends HookWidget {
  const OnlineVoiceBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isMicEnabled = useState(true);
    ZegoServiceManager.shared.deviceService
        .isMicEnabled()
        .then((value) => {isMicEnabled.value = value});

    var isSpeakerEnabled = useState(false);
    ZegoServiceManager.shared.deviceService
        .isSpeakerEnabled()
        .then((value) => {isSpeakerEnabled.value = value});

    return Container(
      padding: EdgeInsets.only(left: 88.w, right: 88.w),
      height: 120.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CallingCalleeBottomToolBarButton(
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: isMicEnabled.value
                  ? StyleIconUrls.toolbarBottomMicOpen
                  : StyleIconUrls.toolbarBottomMicClosed,
              onTap: () async {
                ZegoServiceManager.shared.deviceService
                    .enableMic(isMicEnabled.value);

                isMicEnabled.value = !isMicEnabled.value;
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomEnd,
              onTap: () {
                ZegoCallManager.shared.endCall();
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: isSpeakerEnabled.value
                  ? StyleIconUrls.toolbarBottomSpeakerOpen
                  : StyleIconUrls.toolbarBottomSpeakerClosed,
              onTap: () async {
                ZegoServiceManager.shared.deviceService
                    .enableSpeaker(!isSpeakerEnabled.value);

                isSpeakerEnabled.value = !isSpeakerEnabled.value;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OnlineVideoBottomToolBar extends HookWidget {
  const OnlineVideoBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userService = ZegoServiceManager.shared.userService;
    var deviceService = ZegoServiceManager.shared.deviceService;

    var isCameraEnabled = useState(userService.localUserInfo.camera);
    var isFrontCameraUsed = useState(deviceService.isFrontCamera);
    var isMicEnabled = useState(true);
    var isSpeakerEnabled = useState(true);

    deviceService.isMicEnabled().then((value) => {isMicEnabled.value = value});
    deviceService
        .isSpeakerEnabled()
        .then((value) => {isSpeakerEnabled.value = value});

    return Container(
      padding: EdgeInsets.only(left: 39.w, right: 39.w),
      height: 120.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CallingCalleeBottomToolBarButton(
              iconWidth: 94.w,
              iconHeight: 120.h,
              iconURL: isCameraEnabled.value
                  ? StyleIconUrls.toolbarBottomCameraOpen
                  : StyleIconUrls.toolbarBottomCameraClosed,
              onTap: () {
                ZegoServiceManager.shared.deviceService
                    .enableCamera(!isCameraEnabled.value);

                isCameraEnabled.value = !isCameraEnabled.value;
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 94.w,
              iconHeight: 120.h,
              iconURL: isMicEnabled.value
                  ? StyleIconUrls.toolbarBottomMicOpen
                  : StyleIconUrls.toolbarBottomMicClosed,
              onTap: () async {
                ZegoServiceManager.shared.deviceService
                    .enableMic(!isMicEnabled.value);

                isMicEnabled.value = !isMicEnabled.value;
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomEnd,
              onTap: () {
                ZegoCallManager.shared.endCall();
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 94.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomSwitchCamera,
              onTap: () {
                ZegoServiceManager.shared.deviceService
                    .useFrontCamera(!isFrontCameraUsed.value);

                isFrontCameraUsed.value = !isFrontCameraUsed.value;
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 94.w,
              iconHeight: 120.h,
              iconURL: isSpeakerEnabled.value
                  ? StyleIconUrls.toolbarBottomSpeakerOpen
                  : StyleIconUrls.toolbarBottomSpeakerClosed,
              onTap: () async {
                ZegoServiceManager.shared.deviceService
                    .enableSpeaker(!isSpeakerEnabled.value);

                isSpeakerEnabled.value = !isSpeakerEnabled.value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
