// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../player/zego_video_player.dart';
import 'settings/zego_calling_settings.dart';
import 'toolbar/zego_online_bottom_toolbar.dart';
import 'toolbar/zego_online_top_toolbar.dart';

class ZegoOnlineVideoView extends StatelessWidget {
  const ZegoOnlineVideoView(
      {required this.callID,
      required this.localUser,
      required this.remoteUser,
      Key? key})
      : super(key: key);

  final String callID;
  final ZegoUserInfo localUser;
  final ZegoUserInfo remoteUser;

  Widget topRightVideoPlayerView(ZegoUserInfo targetUser) {
    return Positioned(
      top: 120.h,
      right: 16.w,
      child: SafeArea(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
                width: 190.w,
                height: 338.h,
                child: ZegoVideoPlayer(
                    userID: targetUser.userID, userName: targetUser.userName))),
      ),
    );
  }

  Widget surface(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ZegoOnlineTopToolBar(
            callID: callID,
            settingWidgetHeight: 763.h,
            settingWidget: const ZegoCallingSettingsView(
                callType: ZegoCallType.kZegoCallTypeVideo)),
        const Expanded(child: SizedBox()),
        const ZegoOnlineBottomToolBar(callType: ZegoCallType.kZegoCallTypeVideo),
        SizedBox(height: 105.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ZegoVideoPlayer(
          userID: localUser.userID,
          userName: localUser.userName,
        ),
        topRightVideoPlayerView(remoteUser),
        surface(context),
      ],
    );
  }
}
