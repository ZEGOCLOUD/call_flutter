// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import '../../../core/manager/zego_call_manager.dart';
import './../../../../zegocall/core/model/zego_user_info.dart';
import './../../../../zegocall/core/zego_call_defines.dart';
import './../../../utils/zego_bottom_sheet.dart';
import './../../styles.dart';
import './../settings/zego_calling_settings.dart';
import 'zego_calling_bottom_toolbar_button.dart';

class ZegoCallingCallerVideoTopToolBarButton extends StatelessWidget {
  final String iconURL;
  final VoidCallback onTap;

  const ZegoCallingCallerVideoTopToolBarButton(
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
          ZegoCallingCallerVideoTopToolBarButton(
            iconURL: StyleIconUrls.toolbarTopSwitchCamera,
            onTap: () {
              ZegoServiceManager.shared.deviceService
                  .useFrontCamera(!isFrontCameraUsed.value);

              isFrontCameraUsed.value = !isFrontCameraUsed.value;
            },
          ),
          SizedBox(width: 64.w),
          ZegoCallingCallerVideoTopToolBarButton(
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

class ZegoCallingCallerBottomToolBar extends StatelessWidget {
  const ZegoCallingCallerBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: Center(
        child: GestureDetector(
          onTap: () {
            ZegoCallManager.shared.cancelCall();
          },
          child: SizedBox(
            width: 120.w,
            child: Image.asset(StyleIconUrls.toolbarBottomCancel),
          ),
        ),
      ),
    );
  }
}

class ZegoCallingCalleeBottomToolBar extends StatelessWidget {
  const ZegoCallingCalleeBottomToolBar(
      {required this.caller,
      required this.callee,
      required this.callType,
      Key? key})
      : super(key: key);

  final ZegoCallType callType;
  final ZegoUserInfo caller;
  final ZegoUserInfo callee;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZegoCallingCalleeBottomToolBarButton(
                text: AppLocalizations.of(context)!.callPageActionDecline,
                iconWidth: 120.w,
                iconHeight: 120.h,
                iconURL: StyleIconUrls.toolbarBottomDecline,
                onTap: () {
                  ZegoCallManager.shared.declineCall();
                }),
            SizedBox(
              width: 230.w,
            ),
            ZegoCallingCalleeBottomToolBarButton(
                text: AppLocalizations.of(context)!.callPageActionAccept,
                iconWidth: 120.w,
                iconHeight: 120.h,
                iconURL: imageURLByCallType(callType),
                onTap: () {
                  ZegoCallManager.shared.acceptCall(caller, callType);
                }),
          ],
        ),
      ),
    );
  }

  String imageURLByCallType(ZegoCallType callType) {
    switch (callType) {
      case ZegoCallType.kZegoCallTypeVoice:
        return StyleIconUrls.toolbarBottomVoice;
      case ZegoCallType.kZegoCallTypeVideo:
        return StyleIconUrls.toolbarBottomVideo;
    }
  }
}