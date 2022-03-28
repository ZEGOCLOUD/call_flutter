import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';

import 'package:zego_express_engine/zego_express_engine.dart';

import 'settings_sdk_version_item.dart';

class SettingsVersionBlock extends HookWidget {
  const SettingsVersionBlock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var expressSDKVersion = useState('1.0');
    ZegoExpressEngine.getVersion()
        .then((value) => expressSDKVersion.value = value);

    final zimSDKVersion = useState('1.0');

    final appVersion = useState('1.0');
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appVersion.value = packageInfo.version + "." + packageInfo.buildNumber;
    });

    return Column(
      children: [
        SettingSDKVersionItem(
            title: AppLocalizations.of(context)!.settingPageSdkVersion,
            content: expressSDKVersion.value),
        SettingSDKVersionItem(
            title: AppLocalizations.of(context)!.settingPageZimSdkVersion,
            content: zimSDKVersion.value),
        SettingSDKVersionItem(
            title: AppLocalizations.of(context)!.settingPageVersion,
            content: appVersion.value)
      ]
          .map((e) => Padding(
                child: e,
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ))
          .toList(),
    );
  }
}
