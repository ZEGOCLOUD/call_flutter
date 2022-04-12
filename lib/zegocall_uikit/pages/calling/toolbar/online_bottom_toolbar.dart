// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../../../utils/styles.dart';
import '../../../../zegocall_uikit/core/zego_call_manager.dart';
import '../../../../zegocall/core/interface/zego_device_service.dart';
import 'calling_bottom_toolbar_button.dart';

class OnlineVoiceBottomToolBar extends HookWidget {
  const OnlineVoiceBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var deviceService = context.read<IZegoDeviceService>();
    var isMicEnabled = useState(true);
    deviceService.isMicEnabled().then((value) => {isMicEnabled.value = value});
    var isSpeakerEnabled = useState(false);
    deviceService
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
                var deviceDevice = context.read<IZegoDeviceService>();
                deviceDevice.enableMic(isMicEnabled.value);

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
                var deviceDevice = context.read<IZegoDeviceService>();
                deviceDevice.enableSpeaker(!isSpeakerEnabled.value);

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
    var isCameraEnabled = useState(true);

    var deviceService = context.read<IZegoDeviceService>();
    var isFrontCameraUsed = useState(deviceService.isFrontCamera);
    var isMicEnabled = useState(false);
    deviceService.isMicEnabled().then((value) => {isMicEnabled.value = value});
    var isSpeakerEnabled = useState(false);
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
                var deviceDevice = context.read<IZegoDeviceService>();
                deviceDevice.enableCamera(!isCameraEnabled.value);

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
                var deviceDevice = context.read<IZegoDeviceService>();
                deviceDevice.enableMic(isMicEnabled.value);

                isMicEnabled.value = !isMicEnabled.value;
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomEnd,
              onTap: () {
                // context.read<ZegoCallService>().endCall();
                // TODO end call
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 94.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomSwitchCamera,
              onTap: () {
                var deviceDevice = context.read<IZegoDeviceService>();
                deviceDevice.useFrontCamera(!isFrontCameraUsed.value);

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
                var deviceDevice = context.read<IZegoDeviceService>();
                deviceDevice.enableSpeaker(!isSpeakerEnabled.value);

                isSpeakerEnabled.value = !isSpeakerEnabled.value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
