// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../zegocall_uikit/core/manager/zego_call_manager.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../../constants/user_info.dart';
import './../../styles.dart';
import './../../widgets/toast_manager.dart';
import 'online_list_elements.dart';

class OnlineListItem extends StatelessWidget {
  const OnlineListItem({Key? key, required this.userInfo}) : super(key: key);
  final UserInfo userInfo;

  void onAudioCallTap(BuildContext context) async {
    ZegoCallManager.interface
        .callUser(ZegoUserInfo(userInfo.userID, userInfo.userName),
            ZegoCallType.kZegoCallTypeVoice)
        .then((error) {
      if (ZegoError.success != error) {
        ToastManager.shared.showToast(ZegoError.callStatusWrong == error
            ? AppLocalizations.of(context)!.callPageCallUnableInitiate
            : AppLocalizations.of(context)!.callPageCallFail(error.id));
      }
    });
  }

  void onVideoCallTap(BuildContext context) async {
    ZegoCallManager.interface
        .callUser(ZegoUserInfo(userInfo.userID, userInfo.userName),
            ZegoCallType.kZegoCallTypeVideo)
        .then((error) {
      if (ZegoError.success != error) {
        ToastManager.shared.showToast(ZegoError.callStatusWrong == error
            ? AppLocalizations.of(context)!.callPageCallUnableInitiate
            : AppLocalizations.of(context)!.callPageCallFail(error.id));
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
