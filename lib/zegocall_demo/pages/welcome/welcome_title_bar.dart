// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/zegocall_uikit/core/manager/zego_call_manager.dart';

// Project imports:
import '../../../zegocall_uikit/utils/zego_user_avatar.dart';
import '../../constants/page_constant.dart';
import '../../styles.dart';

class WelcomeTitleBar extends StatefulWidget {
  const WelcomeTitleBar({Key? key}) : super(key: key);

  @override
  WelcomeTitleBarState createState() => WelcomeTitleBarState();
}

class WelcomeTitleBarState extends State<WelcomeTitleBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localUser = ZegoCallManager.interface.localUserInfo;
    var avatarIndex = getUserAvatarIndex(localUser.userName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          maxRadius: 37.w,
          backgroundImage: AssetImage(getUserAvatarURLByIndex(avatarIndex)),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(36.w, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localUser.userName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF1B1B1B),
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp,
                ),
              ),
              Text(
                ("ID: ${localUser.userID}"),
                style: TextStyle(
                  color: const Color(0xFF606060),
                  fontSize: 20.sp,
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox()),
        IconButton(
            icon: Image.asset(StyleIconUrls.titleBarSettings),
            iconSize: 68.w,
            onPressed: () {
              Navigator.pushReplacementNamed(context, PageRouteNames.settings);
            }),
      ],
    );
  }
}
