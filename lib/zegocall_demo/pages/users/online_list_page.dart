// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../constants/page_constant.dart';
import '../../constants/user_info.dart';
import '../../core/user_list_manager.dart';
import '../../styles.dart';
import '../../widgets/navigation_back_bar.dart';
import '../../widgets/toast_manager.dart';
import 'online_list_item.dart';
import 'online_list_title_bar.dart';

class OnlineListPage extends StatefulWidget {
  const OnlineListPage({Key? key}) : super(key: key);

  @override
  OnlineListPageState createState() => OnlineListPageState();
}

class OnlineListPageState extends State<OnlineListPage> {
  @override
  void initState() {
    super.initState();

    ToastManager.shared.showLoading();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            body: SafeArea(
                child: Container(
          padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 5.h),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            NavigationBackBar(
                onBackTap: () {
                  ToastManager.shared.hide();
                },
                targetBackUrl: PageRouteNames.welcome,
                title: AppLocalizations.of(context)!.back,
                titleStyle: StyleConstant.backText),
            SizedBox(height: 10.h),
            const OnlineListTitleBar(),
            Consumer<UserListManager>(builder: (_, userListManager, child) {
              ToastManager.shared.hide();

              return Expanded(
                child: userListManager.userList.isEmpty
                    ? emptyTips(context)
                    : userListView(userListManager),
              );
            }),
          ]),
        ))));
  }

  Widget emptyTips(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 368.h),
        SizedBox(
            width: 100.w,
            height: 100.h,
            child: Image.asset(StyleIconUrls.userListDefault)),
        SizedBox(height: 16.h),
        Text(AppLocalizations.of(context)!.noOnlineUser,
            style: StyleConstant.userListEmptyText),
      ],
    );
  }

  Widget userListView(UserListManager userListManager) {
    return RefreshIndicator(
      onRefresh: () async {
        ToastManager.shared.showLoading();

        UserListManager.shared.updateUser();
      },
      child: ListView.builder(
        itemExtent: 148.h,
        padding: EdgeInsets.only(left: 32.w, right: 32.w),
        itemCount: userListManager.userList.length,
        itemBuilder: (_, i) {
          UserInfo user = userListManager.userList[i];
          return OnlineListItem(userInfo: user);
        },
      ),
    );
  }
}
