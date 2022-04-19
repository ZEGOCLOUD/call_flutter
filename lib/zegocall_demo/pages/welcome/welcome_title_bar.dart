// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../styles.dart';
import '../../../zegocall_uikit/utils/user_avatar.dart';
import './../../constants/zego_page_constant.dart';

class WelcomeTitleBar extends StatefulWidget {
  const WelcomeTitleBar({Key? key}) : super(key: key);

  @override
  _WelcomeTitleBarState createState() => _WelcomeTitleBarState();
}

class _WelcomeTitleBarState extends State<WelcomeTitleBar> {
  late User user;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser!;
    FirebaseAuth.instance.userChanges().listen((event) {
      if (event != null && mounted) {
        setState(() {
          user = event;
        });
      }
    });

    log(user.toString());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(user.displayName ?? "");

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
                user.displayName ?? '',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF1B1B1B),
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp,
                ),
              ),
              Text(
                ("ID: ${user.uid}"),
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
