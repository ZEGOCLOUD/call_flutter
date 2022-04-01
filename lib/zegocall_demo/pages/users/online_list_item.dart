// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall_demo/constants/user_info.dart';
import '../../../zegocall/core/interface/zego_call_service.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import './../../../utils/styles.dart';
import './../../constants/zego_page_constant.dart';
import 'online_list_elements.dart';

class OnlineListItem extends StatelessWidget {
  const OnlineListItem({Key? key, required this.userInfo}) : super(key: key);
  final DemoUserInfo userInfo;

  void onAudioCallTap(BuildContext context) async {
    //  call test
    Navigator.pushReplacementNamed(context, PageRouteNames.calling);

    context.read<IZegoCallService>().callUser(
        ZegoUserInfo(userInfo.userID, userInfo.userName),
        'token',
        ZegoCallType.kZegoCallTypeVoice);
  }

  void onVideoCallTap(BuildContext context) async {
    context.read<IZegoCallService>().callUser(
        ZegoUserInfo(userInfo.userID, userInfo.userName),
        'token',
        ZegoCallType.kZegoCallTypeVideo);
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
