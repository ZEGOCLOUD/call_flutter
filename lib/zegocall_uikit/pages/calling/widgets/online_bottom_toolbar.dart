// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/zegocall/core/interface_imp/zego_call_service_impl.dart';
import 'package:zego_call_flutter/zegocall/core/interface_imp/zego_device_service_impl.dart';
import '../../../../zegocall/core/interface/zego_call_service.dart';
import '../../../../zegocall/core/interface/zego_device_service.dart';
import 'calling_bottom_toolbar_button.dart';

class OnlineVoiceBottomToolBar extends HookWidget {
  const OnlineVoiceBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var deviceService = context.read<IZegoDeviceService>();
    var isMicMuted = useState(false);
    deviceService.isMicMuted().then((value) => {isMicMuted.value = value});
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
              iconURL: isMicMuted.value
                  ? StyleIconUrls.toolbarBottomMicClosed
                  : StyleIconUrls.toolbarBottomMicOpen,
              onTap: () async {
                var deviceDevice = context.read<IZegoDeviceService>();
                deviceDevice.muteMic(!isMicMuted.value);

                isMicMuted.value = !isMicMuted.value;
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomEnd,
              onTap: () {
                context.read<IZegoCallService>().endCall();
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
    var isMicMuted = useState(false);
    deviceService.isMicMuted().then((value) => {isMicMuted.value = value});
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
              iconURL: isMicMuted.value
                  ? StyleIconUrls.toolbarBottomMicClosed
                  : StyleIconUrls.toolbarBottomMicOpen,
              onTap: () async {
                var deviceDevice = context.read<IZegoDeviceService>();
                deviceDevice.muteMic(!isMicMuted.value);

                isMicMuted.value = !isMicMuted.value;
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