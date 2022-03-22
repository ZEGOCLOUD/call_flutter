import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/zego_user_info.dart';
import '../../service/zego_user_service.dart';
import '../navigation_back_bar.dart';
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

      // On calling notification tap
      AwesomeNotifications()
          .actionStream
          .listen((ReceivedNotification receivedNotification) {
        Navigator.of(context).pushNamed(PageRouteNames.calling,
            arguments: receivedNotification.payload);
      });

      return null;
    }, const []);

    return Scaffold(
        body: SafeArea(
            child: Container(
      padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 0),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        NavigationBackBar(targetBackUrl: PageRouteNames.welcome),
        SizedBox(height: 10.h),
        const OnlineListTitleBar(),
        Consumer<ZegoUserService>(
            builder: (_, userService, child) => SizedBox(
                  width: double.infinity,
                  height: 658.h,
                  child: ListView.builder(
                    itemExtent: 148.h,
                    padding: EdgeInsets.only(
                        left: 32.w, top: 32.h, right: 32.w, bottom: 32.h),
                    itemCount: userService.userList.length,
                    itemBuilder: (_, i) {
                      ZegoUserInfo user = userService.userList[i];
                      return OnlineListItem(userInfo: user);
                    },
                  ),
                )),
      ]),
    )));
  }
}
