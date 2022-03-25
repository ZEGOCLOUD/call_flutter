import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zego_call_flutter/common/style/styles.dart';
import 'package:zego_call_flutter/page/calling/avatar_background.dart';
import 'package:zego_call_flutter/page/calling/calling_toolbar.dart';
import 'package:zego_call_flutter/page/calling/video_player.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/user_avatar.dart';
import '../../model/zego_user_info.dart';

//  呼叫端 呼叫界面
class CallingCallerView extends StatefulWidget {
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
  State<StatefulWidget> createState() {
    return CallingCallerViewState();
  }
}

class CallingCallerViewState extends State<CallingCallerView> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      backgroundView(),
      surface(),
    ]);
  }

  Widget backgroundView() {
    if (ZegoCallType.kZegoCallTypeVideo == widget.callType) {
      return VideoPlayerView(
        userID: widget.caller.userID,
        userName: widget.caller.displayName,
      );
    }
    return AvatarBackgroundView(userName: widget.callee.displayName);
  }

  Widget surface() {
    var isVideo = ZegoCallType.kZegoCallTypeVideo == widget.callType;
    var avatarIndex = getUserAvatarIndex(widget.callee.displayName);

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
          child: Text(widget.callee.displayName,
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
