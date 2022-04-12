// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../../zegocall/core/interface/zego_user_service.dart';
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import '../player/video_player.dart';
import 'settings/calling_settings.dart';
import 'toolbar/online_bottom_toolbar.dart';
import 'toolbar/online_top_toolbar.dart';

class OnlineVideoView extends StatelessWidget {
  const OnlineVideoView({required this.caller, required this.callee, Key? key})
      : super(key: key);

  final ZegoUserInfo caller;
  final ZegoUserInfo callee;

  getOtherUserName(BuildContext context) {
    final localUserID = context.read<IZegoUserService>().localUserInfo.userID;
    return localUserID == caller.userID
        ? callee.userName
        : caller.userName;
  }

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
                child: VideoPlayerView(
                  userID: targetUser.userID,
                  userName: targetUser.userName,
                ))),
      ),
    );
  }

  Widget surface(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OnlineTopToolBar(
            settingWidgetHeight: 763.h,
            settingWidget: const CallingSettingsView(
                callType: ZegoCallType.kZegoCallTypeVideo)),
        const Expanded(child: SizedBox()),
        const OnlineVideoBottomToolBar(),
        SizedBox(
          height: 105.h,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayerView(
          userID: caller.userID,
          userName: caller.userName,
        ),
        topRightVideoPlayerView(callee),
        surface(context),
      ],
    );
  }
}
