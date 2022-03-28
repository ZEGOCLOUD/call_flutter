import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/utils/styles.dart';

import 'package:zego_call_flutter/utils/user_avatar.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_call_service.dart';

class MiniOverlayBeInviteFrame extends StatefulWidget {
  MiniOverlayBeInviteFrame(
      {Key? key,
      required this.callerName,
      required this.callerID,
      required this.callType,
      required this.onDecline,
      required this.onAccept})
      : super(key: key);

  String callerID;
  String callerName;
  ZegoCallType callType;
  VoidCallback onDecline;
  VoidCallback onAccept;

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
          backgroundImage: AssetImage("images/avatar_$avatarIndex.png"),
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
            context.read<ZegoCallService>().declineCall(
                'token', ZegoDeclineType.kZegoDeclineTypeDecline);
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
            context
                .read<ZegoCallService>()
                .acceptCall();
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
