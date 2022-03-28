// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/utils/user_avatar.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_call_service.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_user_service.dart';
import 'settings/calling_settings.dart';
import 'widgets/avatar_background.dart';
import 'widgets/online_bottom_toolbar.dart';
import 'widgets/online_top_toolbar.dart';

class OnlineVoiceView extends StatelessWidget {
  const OnlineVoiceView({required this.caller, required this.callee, Key? key})
      : super(key: key);

  final ZegoUserInfo caller;
  final ZegoUserInfo callee;

  getOtherUserName(BuildContext context) {
    final localUserID = context.read<ZegoUserService>().localUserInfo.userID;
    return localUserID == caller.userID
        ? callee.displayName
        : caller.displayName;
  }

  Widget surface(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(getOtherUserName(context));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OnlineTopToolBar(
            settingWidgetHeight: 563.h,
            settingWidget: const CallingSettingsView(
                callType: ZegoCallType.kZegoCallTypeVoice)),
        SizedBox(
          height: 140.h,
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
        Text(
          getOtherUserName(context),
          style: StyleConstant.callingCenterUserName,
        ),
        const Expanded(child: SizedBox()),
        const OnlineVoiceBottomToolBar(),
        SizedBox(
          height: 105.h,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AvatarBackgroundView(userName: getOtherUserName(context)),
      surface(context),
    ]);
  }
}
