// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import './../../../utils/styles.dart';
import './../../../utils/widgets/navigation_back_bar.dart';
import './../../constants/user_info.dart';
import './../../constants/zego_page_constant.dart';
import './../../core/zego_user_list_manager.dart';
import 'online_list_item.dart';
import 'online_list_title_bar.dart';

class OnlineListPage extends HookWidget {
  const OnlineListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 5.h),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        const NavigationBackBar(
            targetBackUrl: PageRouteNames.welcome,
            title: "Back",
            titleStyle: StyleConstant.backText),
        SizedBox(height: 10.h),
        const OnlineListTitleBar(),
        Consumer<ZegoUserListManager>(
            builder: (_, userListManager, child) => SizedBox(
                  width: double.infinity,
                  height: 1080.h,
                  child: userListManager.userList.isEmpty
                      ? emptyTips()
                      : userListView(userListManager),
                )),
      ]),
    )));
  }

  Widget emptyTips() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 368.h),
        SizedBox(
            width: 100.w,
            height: 100.h,
            child: Image.asset(StyleIconUrls.userListDefault)),
        SizedBox(height: 16.h),
        const Text("No Online User", style: StyleConstant.userListEmptyText),
      ],
    );
  }

  Widget userListView(ZegoUserListManager userListManager) {
    return ListView.builder(
      itemExtent: 148.h,
      padding: EdgeInsets.only(left: 32.w, right: 32.w),
      itemCount: userListManager.userList.length,
      itemBuilder: (_, i) {
        DemoUserInfo user = userListManager.userList[i];
        return OnlineListItem(userInfo: user);
      },
    );
  }
}
