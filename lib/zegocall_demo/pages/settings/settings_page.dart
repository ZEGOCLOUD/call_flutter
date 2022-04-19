// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../styles.dart';
import './../../widgets/navigation_back_bar.dart';
import './../../constants/zego_page_constant.dart';
import 'settings_browser_block.dart';
import 'settings_logout_block.dart';
import 'settings_upload_log_block.dart';
import 'settings_version_block.dart';

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
                      NavigationBackBar(
                          targetBackUrl: PageRouteNames.welcome,
                          title:
                              AppLocalizations.of(context)!.settingPageSettings,
                          titleAlign: TextAlign.center,
                          titleStyle: StyleConstant.settingTitle,
                          iconColor: StyleConstant.settingTitle.color),
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
