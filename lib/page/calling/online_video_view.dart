import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_call_flutter/page/calling/calling_toolbar.dart';
import 'package:zego_call_flutter/page/calling/online_toolbar.dart';
import 'package:zego_call_flutter/page/calling/video_player.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/zego_user_info.dart';
import '../../service/zego_user_service.dart';

class OnlineVideoView extends StatelessWidget {
  const OnlineVideoView({required this.caller, required this.callee, Key? key})
      : super(key: key);

  final ZegoUserInfo caller;
  final ZegoUserInfo callee;

  getOtherUserName(BuildContext context) {
    final localUserID = context.read<ZegoUserService>().localUserInfo.userID;
    return localUserID == caller.userID
        ? callee.displayName
        : caller.displayName;
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
                  userName: targetUser.displayName,
                ))),
      ),
    );
  }

  Widget surface(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const OnlineTopToolBar(),
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
          userName: caller.displayName,
        ),
        topRightVideoPlayerView(callee),
        surface(context),
      ],
    );
  }
}