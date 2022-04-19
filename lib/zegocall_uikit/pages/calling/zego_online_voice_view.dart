// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../player/zego_audio_player.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../../utils/zego_user_avatar.dart';
import './../styles.dart';
import 'settings/zego_calling_settings.dart';
import 'toolbar/zego_online_bottom_toolbar.dart';
import 'toolbar/zego_online_top_toolbar.dart';

class ZegoOnlineVoiceView extends StatelessWidget {
  const ZegoOnlineVoiceView(
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
        ZegoOnlineTopToolBar(
            callID: callID,
            settingWidgetHeight: 563.h,
            settingWidget: const ZegoCallingSettingsView(
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
        const ZegoOnlineBottomToolBar(callType: ZegoCallType.kZegoCallTypeVoice),
        SizedBox(height: 105.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ZegoAudioPlayer(
        remoteUserID: remoteUser.userID,
        remoteUserName: remoteUser.userName,
      ),
      surface(context),
    ]);
  }
}
