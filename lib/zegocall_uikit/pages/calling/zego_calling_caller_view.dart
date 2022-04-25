// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import '../../utils/zego_user_avatar.dart';
import '../player/zego_avatar_background.dart';
import '../player/zego_video_player.dart';
import '../styles.dart';
import 'toolbar/zego_calling_bottom_toolbar.dart';
import 'toolbar/zego_calling_top_toolbar.dart';

class ZegoCallingCallerView extends StatelessWidget {
  const ZegoCallingCallerView(
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
    return Stack(children: [backgroundView(), surface(context)]);
  }

  Widget backgroundView() {
    if (ZegoCallType.kZegoCallTypeVideo == callType) {
      return ZegoVideoPlayer(userID: caller.userID, userName: caller.userName);
    }
    return ZegoAvatarBackgroundView(userName: callee.userName);
  }

  Widget surface(BuildContext context) {
    var isVideo = ZegoCallType.kZegoCallTypeVideo == callType;
    var avatarIndex = getUserAvatarIndex(callee.userName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isVideo
            ? const ZegoCallingCallerVideoTopToolBar()
            : const ZegoCallingCallerAudioTopToolBar(),
        isVideo ? SizedBox(height: 140.h) : SizedBox(height: 228.h),
        SizedBox(
          width: 200.w,
          height: 200.h,
          child: CircleAvatar(
            maxRadius: 200.w,
            backgroundImage: AssetImage(getUserAvatarURLByIndex(avatarIndex)),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
            height: 59.h,
            child: Text(callee.userName,
                style: StyleConstant.callingCenterUserName)),
        SizedBox(height: 47.h),
        Text(AppLocalizations.of(context)!.callPageStatusCalling,
            style: StyleConstant.callingCenterStatus),
        const Expanded(child: SizedBox()),
        const ZegoCallingCallerBottomToolBar(),
        SizedBox(height: 105.h),
      ],
    );
  }
}
