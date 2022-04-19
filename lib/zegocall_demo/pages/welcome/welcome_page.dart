// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../zegocall_uikit/core/manager/zego_call_manager.dart';
import './../../core/token_manager.dart';
import 'welcome_one_on_one_bg.dart';
import 'welcome_title_bar.dart';
import 'welcome_tool_bar.dart';

class WelcomePage extends HookWidget {
  // ignore: public_member_api_docs
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      var user = FirebaseAuth.instance.currentUser!;

      ZegoCallManager.interface.setLocalUser(user.uid, user.displayName ?? "");
      // init after set local user
      TokenManager.shared.init();

      return null;
    }, []);

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
