import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';

import '../../common/style/styles.dart';
import '../../model/zego_user_info.dart';

import 'package:zego_call_flutter/page/users/online_list_elements.dart';

class OnlineListItem extends StatelessWidget {
  const OnlineListItem({Key? key, required this.userInfo}) : super(key: key);
  final ZegoUserInfo userInfo;

  void onAudioCallTap() {
    // TODO call to audio
  }

  void onVideoCallTap() {
    // TODO call to video
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 84.w,
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              userInfo.photoUrl,
            ),
          ),
        ),
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
                  userName: userInfo.displayName, userID: userInfo.userID),
              SizedBox(width: 36.w),
              Row(
                children: [
                  GestureDetector(
                      child: const OnlineListButton(
                          iconAssetName: StyleIconUrls.memberAudioCall),
                      onTap: () async {
                        context.read<ZegoCallService>().callUser(
                            userInfo.userID,
                            'token',
                            ZegoCallType.kZegoCallTypeVoice);
                      }),
                  SizedBox(width: 32.w),
                  GestureDetector(
                      child: const OnlineListButton(
                          iconAssetName: StyleIconUrls.memberVideoCall),
                      onTap: () async {
                        context.read<ZegoCallService>().callUser(
                            userInfo.userID,
                            'token',
                            ZegoCallType.kZegoCallTypeVideo);
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
