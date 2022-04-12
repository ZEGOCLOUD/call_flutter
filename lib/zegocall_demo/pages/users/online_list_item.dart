// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../../utils/styles.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../../../zegocall_uikit/core/zego_call_manager.dart';
import './../../constants/user_info.dart';
import 'online_list_elements.dart';

class OnlineListItem extends StatelessWidget {
  const OnlineListItem({Key? key, required this.userInfo}) : super(key: key);
  final DemoUserInfo userInfo;

  void onAudioCallTap(BuildContext context) async {
    ZegoCallManager.shared
        .callUser(ZegoUserInfo(userInfo.userID, userInfo.userName),
            ZegoCallType.kZegoCallTypeVoice)
        .then((error) {
      if (ZegoError.success != error) {
        //  todo show tips
      }
    });
  }

  void onVideoCallTap(BuildContext context) async {
    ZegoCallManager.shared
        .callUser(ZegoUserInfo(userInfo.userID, userInfo.userName),
            ZegoCallType.kZegoCallTypeVideo)
        .then((error) {
      if (ZegoError.success != error) {
        //  todo show tips
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OnlineListAvatar(userName: userInfo.userName),
        SizedBox(width: 26.w),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  width: 1.0, color: StyleColors.userListSeparateLineColor),
            ),
          ),
          child: Row(
            children: [
              OnlineListUserInfo(
                  userName: userInfo.userName, userID: userInfo.userID),
              SizedBox(width: 36.w),
              Row(
                children: [
                  GestureDetector(
                      child: const OnlineListButton(
                          iconAssetName: StyleIconUrls.userListAudioCall),
                      onTap: () {
                        onAudioCallTap(context);
                      }),
                  SizedBox(width: 32.w),
                  GestureDetector(
                      child: const OnlineListButton(
                          iconAssetName: StyleIconUrls.userLIstVideoCall),
                      onTap: () {
                        onVideoCallTap(context);
                      }),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
