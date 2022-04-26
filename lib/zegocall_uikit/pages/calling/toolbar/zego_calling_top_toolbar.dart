// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../../zegocall/core/manager/zego_service_manager.dart';
import '../../../../zegocall/core/model/zego_user_info.dart';
import '../../../../zegocall/core/zego_call_defines.dart';
import '../../../core/manager/zego_call_manager.dart';
import '../../../core/manager/zego_call_manager_interface.dart';
import '../../../utils/zego_bottom_sheet.dart';
import '../../styles.dart';
import '../settings/zego_calling_settings.dart';
import 'zego_calling_bottom_toolbar_button.dart';

class ZegoCallingTopToolBarButton extends StatelessWidget {
  final String iconURL;
  final VoidCallback onTap;

  const ZegoCallingTopToolBarButton(
      {required this.iconURL, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44.w,
        child: Image.asset(iconURL),
      ),
    );
  }
}

class ZegoCallingCallerVideoTopToolBar extends HookWidget {
  const ZegoCallingCallerVideoTopToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isFrontCameraUsed =
        useState(ZegoServiceManager.shared.deviceService.isFrontCamera);

    return SafeArea(
        child: Container(
      //test
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
      ),
      padding: EdgeInsets.only(left: 36.w, right: 36.w),
      height: 88.h,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ZegoCallingTopToolBarButton(
            iconURL: StyleIconUrls.toolbarTopMini,
            onTap: () {
              ZegoCallManager.shared.onMiniOverlayRequest();
            },
          ),
          const Expanded(child: SizedBox()),
          ZegoCallingTopToolBarButton(
            iconURL: StyleIconUrls.toolbarTopSwitchCamera,
            onTap: () {
              ZegoServiceManager.shared.deviceService
                  .useFrontCamera(!isFrontCameraUsed.value);

              isFrontCameraUsed.value = !isFrontCameraUsed.value;
            },
          ),
          SizedBox(width: 64.w),
          ZegoCallingTopToolBarButton(
            iconURL: StyleIconUrls.toolbarTopSettings,
            onTap: () {
              showModalBottomSheetWithStyle(
                  context,
                  763.h,
                  const ZegoCallingSettingsView(
                      callType: ZegoCallType.kZegoCallTypeVideo));
            },
          ),
        ],
      ),
    ));
  }
}

class ZegoCallingCallerAudioTopToolBar extends HookWidget {
  const ZegoCallingCallerAudioTopToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      //test
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
      ),
      padding: EdgeInsets.only(left: 36.w, right: 36.w),
      height: 88.h,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ZegoCallingTopToolBarButton(
            iconURL: StyleIconUrls.toolbarTopMini,
            onTap: () {
              ZegoCallManager.shared.onMiniOverlayRequest();
            },
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    ));
  }
}
