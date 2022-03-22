import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zego_call_flutter/page/settings/settings_browser_block.dart';
import 'package:zego_call_flutter/page/settings/settings_logout_block.dart';
import 'package:zego_call_flutter/page/settings/settings_upload_log_block.dart';
import 'package:zego_call_flutter/page/settings/settings_version_block.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/style/styles.dart';
import '../../constants/zego_page_constant.dart';
import '../navigation_back_bar.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                padding:
                    EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      NavigationBackBar(targetBackUrl: PageRouteNames.welcome),
                      Container(
                          decoration: const BoxDecoration(
                              color: StyleColors.settingsBackgroundColor),
                          child: Column(children: [
                            SizedBox(height: 24.h),
                            const SettingsVersionBlock(),
                            SizedBox(height: 24.h),
                            const SettingsBrowserBlock(),
                            SizedBox(height: 24.h),
                            const SettingsUploadLogBlock(),
                            SizedBox(height: 80.h),
                            const SettingsLogoutBlock()
                          ])),
                    ]))));
  }
}
