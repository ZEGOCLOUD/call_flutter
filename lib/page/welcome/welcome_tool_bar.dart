import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/common/style/styles.dart';

import '../../service/zego_user_service.dart';

class WelcomeToolBar extends StatelessWidget {
  const WelcomeToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Contact us button
        Container(
          width: 320.w,
          height: 98.h,
          decoration: const BoxDecoration(
            color: Color(0xffF3F4F7),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage(StyleIconUrls.welcomeContactUs),
              ),
              TextButton(
                  onPressed: () {
                    // TODO jump to contact us
                  },
                  child: const Text(
                    'Contact us',
                    style: TextStyle(color: Color(0xff2A2A2A)),
                  )),
            ],
          ),
        ),
        SizedBox(
          width: 20.w,
        ),
        // Get more button
        Container(
          width: 320.w,
          height: 98.h,
          decoration: const BoxDecoration(
            color: Color(0xffF3F4F7),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage(StyleIconUrls.welcomeGetMore),
              ),
              TextButton(
                  onPressed: () {
                    // TODO jump to contact us
                    var userService = context.read<ZegoUserService>();
                    userService.getOnlineUsers();
                  },
                  child: const Text(
                    'Get more',
                    style: TextStyle(color: Color(0xff2A2A2A)),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}