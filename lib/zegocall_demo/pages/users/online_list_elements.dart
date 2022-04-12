// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../../utils/styles.dart';
import './../../../utils/user_avatar.dart';

class OnlineListAvatar extends StatelessWidget {
  final String userName;

  const OnlineListAvatar({required this.userName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(userName);
    return SizedBox(
      width: 84.w,
      child: CircleAvatar(
        foregroundImage: AssetImage(getUserAvatarURLByIndex(avatarIndex)),
      ),
    );
  }
}

class OnlineListUserInfo extends StatelessWidget {
  final String userID;
  final String userName;

  const OnlineListUserInfo(
      {required this.userID, required this.userName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: Text('')),
        SizedBox(
          width: 340.w,
          height: 45.h,
          child: Text(userName, style: StyleConstant.userListNameText),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 340.w,
          height: 33.h,
          child: Text("ID:$userID",
              maxLines: 1, style: StyleConstant.userListIDText),
        ),
        const Expanded(child: Text('')),
      ],
    );
  }
}

class OnlineListButton extends StatelessWidget {
  final String iconAssetName;

  const OnlineListButton({required this.iconAssetName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
        child: Container(
            width: 84.w,
            decoration: const BoxDecoration(
              color: StyleColors.userListButtonBgColor,
            ),
            child: Image(
              image: AssetImage(iconAssetName),
            )));
  }
}
