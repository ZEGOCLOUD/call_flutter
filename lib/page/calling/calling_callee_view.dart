import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zego_call_flutter/page/calling/avatar_background.dart';
import 'package:zego_call_flutter/page/calling/calling_toolbar.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/style/styles.dart';
import '../../common/user_avatar.dart';
import '../../model/zego_user_info.dart';

class CallingCalleeView extends StatelessWidget {
  const CallingCalleeView(
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
      AvatarBackgroundView(userName: caller.displayName),
      surface(),
    ]);
  }

  Widget surface() {
    var avatarIndex = getUserAvatarIndex(callee.displayName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 280.h,
        ),
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
          child: Text(callee.displayName,
              style: StyleConstant.callingCenterUserName),
        ),
        SizedBox(
          height: 47.h,
        ),
        const Text('Calling...', style: StyleConstant.callingCenterStatus),
        const Expanded(child: SizedBox()),
        CallingCalleeBottomToolBar(callType: callType),
        SizedBox(
          height: 105.h,
        ),
      ],
    );
  }
}
