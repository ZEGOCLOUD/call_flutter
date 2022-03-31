// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/utils/widgets/navigation_back_bar.dart';
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import 'package:zego_call_flutter/zegocall/core/model/zego_user_info.dart';
import 'package:zego_call_flutter/zegocall_demo/constants/user_info.dart';
import 'package:zego_call_flutter/zegocall_demo/constants/zego_page_constant.dart';
import 'package:zego_call_flutter/zegocall_demo/firebase/zego_user_list_manager.dart';
import 'online_list_item.dart';
import 'online_list_title_bar.dart';

class OnlineListPage extends HookWidget {
  const OnlineListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      ZegoUserListManager.shared.getOnlineUsers();

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

      //  call test
      ZegoServiceManager.shared
          .initWithAPPID(
              841790877,
              'f12db2b9deddd08ba8'
              '1608c2023997c7')
          .then((value) {
        ZegoServiceManager.shared.roomService.joinRoom('999', '');
      });

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
        Consumer<ZegoUserListManager>(
            builder: (_, userListManager, child) => RefreshIndicator(
                onRefresh: () async {
                  ZegoUserListManager.shared.getOnlineUsers();
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 1080.h,
                  child: userListManager.userList.isEmpty
                      ? emptyTips()
                      : userListView(userListManager),
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
