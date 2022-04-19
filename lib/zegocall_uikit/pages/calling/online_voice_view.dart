// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../player/audio_player.dart';
import './../styles.dart';
import './../../utils/user_avatar.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import 'settings/calling_settings.dart';
import 'toolbar/online_bottom_toolbar.dart';
import 'toolbar/online_top_toolbar.dart';

class OnlineVoiceView extends StatelessWidget {
  const OnlineVoiceView(
      {required this.callID,
      required this.localUser,
      required this.remoteUser,
      Key? key})
      : super(key: key);

  final String callID;
  final ZegoUserInfo localUser;
  final ZegoUserInfo remoteUser;

  Widget surface(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(remoteUser.userName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OnlineTopToolBar(
            callID: callID,
            settingWidgetHeight: 563.h,
            settingWidget: const CallingSettingsView(
                callType: ZegoCallType.kZegoCallTypeVoice)),
        SizedBox(height: 140.h),
        SizedBox(
            width: 200.w,
            height: 200.h,
            child: CircleAvatar(
              maxRadius: 200.w,
              backgroundImage: AssetImage(getUserAvatarURLByIndex(avatarIndex)),
            )),
        SizedBox(height: 10.h),
        Text(
          remoteUser.userName,
          style: StyleConstant.callingCenterUserName,
        ),
        const Expanded(child: SizedBox()),
        const OnlineBottomToolBar(callType: ZegoCallType.kZegoCallTypeVoice),
        SizedBox(height: 105.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AudioPlayer(
        remoteUserID: remoteUser.userID,
        remoteUserName: remoteUser.userName,
      ),
      surface(context),
    ]);
  }
}
