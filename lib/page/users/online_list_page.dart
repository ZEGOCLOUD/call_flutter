import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zego_call_flutter/common/style/styles.dart';
import 'package:zego_call_flutter/model/zego_user_info.dart';
import 'package:zego_call_flutter/service/zego_user_service.dart';
import 'package:zego_call_flutter/page/navigation_back_bar.dart';
import 'online_list_item.dart';
import 'online_list_title_bar.dart';
import 'package:zego_call_flutter/constants/zego_page_constant.dart';

class OnlineListPage extends HookWidget {
  const OnlineListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      var userService = context.read<ZegoUserService>();
      userService.getOnlineUsers();

      try {
        // On calling notification tap
        AwesomeNotifications()
            .actionStream
            .listen((ReceivedNotification receivedNotification) {
          Navigator.of(context).pushNamed(PageRouteNames.calling,
              arguments: receivedNotification.payload);
        });
      } catch (e) {
        print(e);
      }

      return null;
    }, const []);

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
        Consumer<ZegoUserService>(
            builder: (_, userService, child) => RefreshIndicator(
                onRefresh: () async {
                  userService.getOnlineUsers();
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 1080.h,
                  child: userService.userList.isEmpty
                      ? emptyTips()
                      : userListView(userService),
                ))),
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

  Widget userListView(ZegoUserService userService) {
    return ListView.builder(
      itemExtent: 148.h,
      padding: EdgeInsets.only(left: 32.w, right: 32.w),
      itemCount: userService.userList.length,
      itemBuilder: (_, i) {
        ZegoUserInfo user = userService.userList[i];
        return OnlineListItem(userInfo: user);
      },
    );
  }
}
