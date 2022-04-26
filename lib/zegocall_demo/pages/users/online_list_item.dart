// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import '../../../zegocall_uikit/core/manager/zego_call_manager.dart';
import '../../constants/user_info.dart';
import '../../core/permission_manager.dart';
import '../../styles.dart';
import '../../widgets/toast_manager.dart';
import 'online_list_elements.dart';

class OnlineListItem extends StatefulWidget {
  const OnlineListItem({Key? key, required this.userInfo}) : super(key: key);

  final UserInfo userInfo;

  @override
  OnlineListItemState createState() => OnlineListItemState();
}

class OnlineListItemState extends State<OnlineListItem> {
  bool isLoading = false;

  void onAudioCallTap(BuildContext context) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    ToastManager.shared.showLoading();

    executeInPermission(context, () {
      ZegoCallManager.interface
          .callUser(
              ZegoUserInfo(widget.userInfo.userID, widget.userInfo.userName),
              ZegoCallType.kZegoCallTypeVoice)
          .then((error) {
        isLoading = false;
        ToastManager.shared.hide();

        if (ZegoError.success != error) {
          ToastManager.shared.showToast(ZegoError.callStatusWrong == error
              ? AppLocalizations.of(context)!.callPageCallUnableInitiate
              : AppLocalizations.of(context)!.callPageCallFail(error.id));
        }
      });
    });
  }

  void onVideoCallTap(BuildContext context) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    ToastManager.shared.showLoading();

    executeInPermission(context, () {
      ZegoCallManager.interface
          .callUser(
              ZegoUserInfo(widget.userInfo.userID, widget.userInfo.userName),
              ZegoCallType.kZegoCallTypeVideo)
          .then((error) {
        isLoading = false;
        ToastManager.shared.hide();

        if (ZegoError.success != error) {
          ToastManager.shared.showToast(ZegoError.callStatusWrong == error
              ? AppLocalizations.of(context)!.callPageCallUnableInitiate
              : AppLocalizations.of(context)!.callPageCallFail(error.id));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      OnlineListAvatar(userName: widget.userInfo.userName),
      SizedBox(width: 26.w),
      Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  width: 1.0, color: StyleColors.userListSeparateLineColor),
            ),
          ),
          child: Row(children: [
            OnlineListUserInfo(
                userName: widget.userInfo.userName,
                userID: widget.userInfo.userID),
            SizedBox(width: 36.w),
            Row(children: [
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
                  })
            ])
          ]))
    ]);
  }
}
