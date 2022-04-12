// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../utils/styles.dart';
import '../../../utils/user_avatar.dart';
import '../../../zegocall/core/zego_call_defines.dart';

class MiniOverlayBeInvite extends StatefulWidget {
  const MiniOverlayBeInvite({
    Key? key,
    required this.callerName,
    required this.callerID,
    required this.callType,
    required this.onDecline,
    required this.onAccept,
    required this.onEmptyClick,
  }) : super(key: key);

  final String callerID;
  final String callerName;
  final ZegoCallType callType;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final VoidCallback onEmptyClick;

  @override
  _MiniOverlayBeInvite createState() => _MiniOverlayBeInvite();
}

class _MiniOverlayBeInvite extends State<MiniOverlayBeInvite> {
  @override
  Widget build(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(widget.callerName);

    return GestureDetector(
        onTap: () {
          widget.onEmptyClick();
        },
        child: Row(
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
                widget.onAccept();
              },
              child: SizedBox(
                width: 74.w,
                child: Image.asset(imageURLByCallType(widget.callType)),
              ),
            ),
          ],
        ));
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
