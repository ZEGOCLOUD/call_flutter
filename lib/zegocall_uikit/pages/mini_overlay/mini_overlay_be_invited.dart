// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../core/manager/zego_call_manager.dart';
import './../../../utils/styles.dart';
import './../../../utils/user_avatar.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';

class MiniOverlayBeInvite extends StatefulWidget {
  const MiniOverlayBeInvite({
    Key? key,
    required this.caller,
    required this.callType,
  }) : super(key: key);

  final ZegoUserInfo caller;
  final ZegoCallType callType;

  @override
  _MiniOverlayBeInvite createState() => _MiniOverlayBeInvite();
}

class _MiniOverlayBeInvite extends State<MiniOverlayBeInvite> {
  @override
  Widget build(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(widget.caller.userName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
            maxRadius: 84.w,
            backgroundImage: AssetImage(getUserAvatarURLByIndex(avatarIndex))),
        SizedBox(width: 26.w),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.caller.userName,
                  style: StyleConstant.inviteUserName,
                  textAlign: TextAlign.left),
              SizedBox(height: 7.h),
              Text(callTypeString(widget.callType),
                  style: StyleConstant.inviteCallType)
            ]),
        const Expanded(child: Text("")),
        GestureDetector(
            onTap: () {
              ZegoCallManager.shared.declineCall();
            },
            child: SizedBox(
                width: 74.w, child: Image.asset(StyleIconUrls.inviteReject))),
        SizedBox(
          width: 40.w,
        ),
        GestureDetector(
            onTap: () {
              ZegoCallManager.shared.acceptCall(widget.caller, widget.callType);
            },
            child: SizedBox(
                width: 74.w,
                child: Image.asset(imageURLByCallType(widget.callType)))),
      ],
    );
  }

  String imageURLByCallType(ZegoCallType callType) {
    switch (callType) {
      case ZegoCallType.kZegoCallTypeVoice:
        return StyleIconUrls.inviteVoice;
      case ZegoCallType.kZegoCallTypeVideo:
        return StyleIconUrls.inviteVideo;
    }
  }

  String callTypeString(ZegoCallType callType) {
    switch (callType) {
      case ZegoCallType.kZegoCallTypeVoice:
        return "Zego Voice Call";
      case ZegoCallType.kZegoCallTypeVideo:
        return "Zego Video Call";
    }
  }
}
