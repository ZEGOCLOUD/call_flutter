import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:zego_call_flutter/common/style/styles.dart';

import '../../model/zego_user_info.dart';
import '../../service/zego_user_service.dart';
import 'online_list_item.dart';

class OnlineListPage extends StatelessWidget {
  const OnlineListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            height: 72.h,
            width: double.infinity,
            child: Consumer<ZegoUserService>(
                builder: (_, userService, child) =>
                    Center(child: Text('Online Users')))),
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
    ));
  }
}
