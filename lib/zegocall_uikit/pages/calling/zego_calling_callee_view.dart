// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../styles.dart';
import './../../utils/zego_user_avatar.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../player/zego_avatar_background.dart';
import 'toolbar/zego_calling_toolbar.dart';

class ZegoCallingCalleeView extends StatelessWidget {
  const ZegoCallingCalleeView(
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
      ZegoAvatarBackgroundView(userName: caller.userName),
      surface(context),
    ]);
  }

  Widget surface(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(callee.userName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 280.h),
        SizedBox(
            width: 200.w,
            height: 200.h,
            child: CircleAvatar(
              maxRadius: 200.w,
              backgroundImage: AssetImage(getUserAvatarURLByIndex(avatarIndex)),
            )),
        SizedBox(height: 10.h),
        SizedBox(
            height: 59.h,
            child: Text(callee.userName,
                style: StyleConstant.callingCenterUserName)),
        SizedBox(height: 47.h),
        Text(AppLocalizations.of(context)!.callPageStatusCalling,
            style: StyleConstant.callingCenterStatus),
        const Expanded(child: SizedBox()),
        ZegoCallingCalleeBottomToolBar(
            caller: caller, callee: callee, callType: callType),
        SizedBox(height: 105.h),
      ],
    );
  }
}
