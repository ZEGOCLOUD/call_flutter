// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/utils/user_avatar.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import 'widgets/avatar_background.dart';
import 'widgets/calling_toolbar.dart';
import 'widgets/video_player.dart';

class CallingCallerView extends StatelessWidget {
  const CallingCallerView(
      {required this.caller,
      required this.callee,
      required this.callType,
      Key? key})
      : super(key: key);

  final ZegoUserInfo caller;
  final ZegoUserInfo callee;
  final ZegoCallType callType;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      backgroundView(),
      surface(),
    ]);
  }

  Widget backgroundView() {
    if (ZegoCallType.kZegoCallTypeVideo == callType) {
      return VideoPlayerView(
        userID: caller.userID,
        userName: caller.userName,
      );
    }
    return AvatarBackgroundView(userName: callee.userName);
  }

  Widget surface() {
    var isVideo = ZegoCallType.kZegoCallTypeVideo == callType;
    var avatarIndex = getUserAvatarIndex(callee.userName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isVideo ? const CallingCallerVideoTopToolBar() : const SizedBox(),
        isVideo
            ? SizedBox(
                height: 140.h,
              )
            : SizedBox(height: 228.h),
        SizedBox(
          width: 200.w,
          height: 200.h,
          child: CircleAvatar(
            maxRadius: 200.w,
            backgroundImage: AssetImage("images/avatar_$avatarIndex.png"),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        SizedBox(
          height: 59.h,
          child: Text(callee.userName,
              style: StyleConstant.callingCenterUserName),
        ),
        SizedBox(
          height: 47.h,
        ),
        const Text('Calling...', style: StyleConstant.callingCenterStatus),
        const Expanded(child: SizedBox()),
        const CallingCallerBottomToolBar(),
        SizedBox(
          height: 105.h,
        ),
      ],
    );
  }
}