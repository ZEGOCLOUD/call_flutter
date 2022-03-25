import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zego_call_flutter/common/style/styles.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'calling_bottom_toolbar_button.dart';

class OnlineTopToolBar extends StatelessWidget {
  const OnlineTopToolBar({Key? key}) : super(key: key);

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              //  todo
            },
            child: SizedBox(
              width: 44.w,
              child: Image.asset(StyleIconUrls.toolbarTopMini),
            ),
          ),
          SizedBox(width: 8.w),
          const Expanded(
              child: Text(
            '00:01',
            textAlign: TextAlign.center,
            style: StyleConstant.onlineCountDown,
          )),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              //  todo
            },
            child: SizedBox(
              width: 44.w,
              child: Image.asset(StyleIconUrls.toolbarTopSettings),
            ),
          )
        ],
      ),
    ));
  }
}

class OnlineVoiceBottomToolBar extends StatelessWidget {
  const OnlineVoiceBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              iconURL: StyleIconUrls.toolbarBottomMicOpen,
              onTap: () {
                // TODO toggle mic
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
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomSpeakerOpen,
              onTap: () {
                // TODO toggle speaker
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OnlineVideoBottomToolBar extends StatelessWidget {
  const OnlineVideoBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              iconURL: StyleIconUrls.toolbarBottomCameraOpen,
              onTap: () {
                // TODO toggle camera
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 94.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomMicOpen,
              onTap: () {
                // TODO toggle mic
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
                // TODO switch camera
              },
            ),
            CallingCalleeBottomToolBarButton(
              iconWidth: 94.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomSpeakerOpen,
              onTap: () {
                // TODO toggle speaker
              },
            ),
          ],
        ),
      ),
    );
  }
}
