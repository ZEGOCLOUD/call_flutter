import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zego_call_flutter/common/style/styles.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'calling_bottom_toolbar_button.dart';

class CallingCallerVideoTopToolBarButton extends StatelessWidget {
  final String iconURL;
  final VoidCallback onTap;

  const CallingCallerVideoTopToolBarButton(
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

class CallingCallerVideoTopToolBar extends StatelessWidget {
  const CallingCallerVideoTopToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CallingCallerVideoTopToolBarButton(
            iconURL: StyleIconUrls.toolbarBottomSwitchCamera,
            onTap: () {
              //  todo
            },
          ),
          SizedBox(width: 64.w),
          CallingCallerVideoTopToolBarButton(
            iconURL: StyleIconUrls.toolbarTopSettings,
            onTap: () {
              //  todo
            },
          ),
        ],
      ),
    );
  }
}

class CallingCallerBottomToolBar extends StatelessWidget {
  const CallingCallerBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: Center(
        child: GestureDetector(
          onTap: () {
            //  todo
            context.read<ZegoCallService>().cancelCall();
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

class CallingCalleeBottomToolBar extends StatelessWidget {
  const CallingCalleeBottomToolBar({required this.callType, Key? key})
      : super(key: key);

  final ZegoCallType callType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CallingCalleeBottomToolBarButton(
                text: "Decline",
                iconWidth: 120.w,
                iconHeight: 120.h,
                iconURL: StyleIconUrls.toolbarBottomDecline,
                onTap: () {
                  //  todo
                  context.read<ZegoCallService>().declineCall(
                      'token', ZegoDeclineType.kZegoDeclineTypeDecline);
                }),
            SizedBox(
              width: 230.w,
            ),
            CallingCalleeBottomToolBarButton(
                text: "Accept",
                iconWidth: 120.w,
                iconHeight: 120.h,
                iconURL: imageURLByCallType(callType),
                onTap: () {
                  //  todo
                  context.read<ZegoCallService>().acceptCall();
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
