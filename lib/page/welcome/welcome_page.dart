import 'package:flutter/material.dart';

import 'package:zego_call_flutter/page/welcome/welcome_one_on_one_bg.dart';
import 'package:zego_call_flutter/page/welcome/welcome_title_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/page/welcome/welcome_tool_bar.dart';

class ProfilePage extends StatelessWidget {
  // ignore: public_member_api_docs
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  const WelcomeTitleBar(),
                  const WelcomeOneOnOneBg(),
                  const Expanded(child: SizedBox()),
                  const WelcomeToolBar(),
                  SizedBox(
                    height: 96.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
