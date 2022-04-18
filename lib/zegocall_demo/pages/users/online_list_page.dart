// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../../utils/zego_loading_manager.dart';
import './../../../utils/styles.dart';
import './../../../utils/widgets/navigation_back_bar.dart';
import './../../constants/user_info.dart';
import './../../constants/zego_page_constant.dart';
import './../../core/zego_user_list_manager.dart';
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

    ZegoToastManager.shared.showLoading();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 5.h),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        NavigationBackBar(
            targetBackUrl: PageRouteNames.welcome,
            title: AppLocalizations.of(context)!.back,
            titleStyle: StyleConstant.backText),
        SizedBox(height: 10.h),
        const OnlineListTitleBar(),
        Consumer<ZegoUserListManager>(builder: (_, userListManager, child) {
          ZegoToastManager.shared.hide();

          return SizedBox(
            width: double.infinity,
            height: 1080.h,
            child: userListManager.userList.isEmpty
                ? emptyTips(context)
                : userListView(userListManager),
          );
        }),
      ]),
    )));
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

  Widget userListView(ZegoUserListManager userListManager) {
    return RefreshIndicator(
      onRefresh: () async {
        ZegoToastManager.shared.showLoading();

        ZegoUserListManager.shared.updateUser();
      },
      child: ListView.builder(
        itemExtent: 148.h,
        padding: EdgeInsets.only(left: 32.w, right: 32.w),
        itemCount: userListManager.userList.length,
        itemBuilder: (_, i) {
          DemoUserInfo user = userListManager.userList[i];
          return OnlineListItem(userInfo: user);
        },
      ),
    );
  }
}
