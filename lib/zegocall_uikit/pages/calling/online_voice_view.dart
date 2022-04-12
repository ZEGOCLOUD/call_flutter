// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import './../../../utils/styles.dart';
import './../../../utils/user_avatar.dart';
import './../../../zegocall/core/interface/zego_user_service.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../player/avatar_background.dart';
import 'settings/calling_settings.dart';
import 'toolbar/online_bottom_toolbar.dart';
import 'toolbar/online_top_toolbar.dart';

class OnlineVoiceView extends StatelessWidget {
  const OnlineVoiceView({required this.caller, required this.callee, Key? key})
      : super(key: key);

  final ZegoUserInfo caller;
  final ZegoUserInfo callee;

  getOtherUserName(BuildContext context) {
    final localUserID = context.read<IZegoUserService>().localUserInfo.userID;
    return localUserID == caller.userID ? callee.userName : caller.userName;
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
            backgroundImage: AssetImage(getUserAvatarURLByIndex(avatarIndex)),
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
