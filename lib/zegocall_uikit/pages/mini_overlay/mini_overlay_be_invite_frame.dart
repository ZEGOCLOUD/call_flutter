// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/utils/user_avatar.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

import '../../../zegocall/core/delegate/zego_call_service_delegate.dart';
import '../../../zegocall/core/interface/zego_call_service.dart';
import 'mini_overlay_page_delegate_notifier.dart';

class MiniOverlayBeInviteFrame extends StatefulWidget {
  const MiniOverlayBeInviteFrame(
      {Key? key,
      required this.callerName,
      required this.callerID,
      required this.callType,
      required this.onDecline,
      required this.onAccept,
      required this.delegateNotifier})
      : super(key: key);

  final String callerID;
  final String callerName;
  final ZegoCallType callType;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final ZegoOverlayPageDelegatePageNotifier delegateNotifier;

  @override
  _MiniOverlayBeInviteFrame createState() => _MiniOverlayBeInviteFrame();
}

class _MiniOverlayBeInviteFrame extends State<MiniOverlayBeInviteFrame>
    with ZegoCallServiceDelegate {
  @override
  void initState() {
    super.initState();

    initDelegateNotifier();
  }

  @override
  void onReceiveCallAccept(ZegoUserInfo info) {
    // TODO: implement onReceiveCallAccept
  }

  @override
  void onReceiveCallCanceled(ZegoUserInfo info) {
    // TODO: implement onReceiveCallCanceled
  }

  @override
  void onReceiveCallDecline(ZegoUserInfo info, ZegoDeclineType type) {
    // TODO: implement onReceiveCallDecline
  }

  @override
  void onReceiveCallEnded() {
    // TODO: implement onReceiveCallEnded
  }

  @override
  void onReceiveCallInvite(ZegoUserInfo info, ZegoCallType type) {
    // TODO: implement onReceiveCallInvite
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo info, ZegoCallTimeoutType type) {
    // TODO: implement onReceiveCallTimeout
  }

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
            context
                .read<IZegoCallService>()
                .declineCall('token', ZegoDeclineType.kZegoDeclineTypeDecline);
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

  void initDelegateNotifier() {
    widget.delegateNotifier.onPageReceiveCallInvite = onReceiveCallInvite;
    widget.delegateNotifier.onPageReceiveCallCanceled = onReceiveCallCanceled;
    widget.delegateNotifier.onPageReceiveCallAccept = onReceiveCallAccept;
    widget.delegateNotifier.onPageReceiveCallDecline = onReceiveCallDecline;
    widget.delegateNotifier.onPageReceiveCallEnded = onReceiveCallEnded;
    widget.delegateNotifier.onPageReceiveCallTimeout = onReceiveCallTimeout;
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
