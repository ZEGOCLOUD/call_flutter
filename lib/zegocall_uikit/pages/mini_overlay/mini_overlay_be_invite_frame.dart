// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/utils/user_avatar.dart';
import '../../../zegocall/core/interface/zego_call_service.dart';
import '../../../zegocall/core/zego_call_defines.dart';

class MiniOverlayBeInviteFrame extends StatefulWidget {
  const MiniOverlayBeInviteFrame(
      {Key? key,
      required this.callerName,
      required this.callerID,
      required this.callType,
      required this.onDecline,
      required this.onAccept})
      : super(key: key);

  final String callerID;
  final String callerName;
  final ZegoCallType callType;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  _MiniOverlayBeInviteFrame createState() => _MiniOverlayBeInviteFrame();
}

class _MiniOverlayBeInviteFrame extends State<MiniOverlayBeInviteFrame> {
  @override
  Widget build(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(widget.callerName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          maxRadius: 84.w,
          backgroundImage: AssetImage(getUserAvatarURLByIndex(avatarIndex)),
        ),
        SizedBox(
          width: 26.w,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.callerName,
              style: StyleConstant.inviteUserName,
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 7.h,
            ),
            Text(callTypeString(widget.callType),
                style: StyleConstant.inviteCallType),
          ],
        ),
        const Expanded(child: Text("")),
        GestureDetector(
          onTap: () {
            context.read<IZegoCallService>().declineCall();
            widget.onDecline();
          },
          child: SizedBox(
            width: 74.w,
            child: Image.asset(StyleIconUrls.inviteReject),
          ),
        ),
        SizedBox(
          width: 40.w,
        ),
        GestureDetector(
          onTap: () {
            context.read<IZegoCallService>().acceptCall("");
            widget.onAccept();
          },
          child: SizedBox(
            width: 74.w,
            child: Image.asset(imageURLByCallType(widget.callType)),
          ),
        ),
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
