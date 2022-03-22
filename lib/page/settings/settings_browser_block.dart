import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:zego_call_flutter/page/settings/settings_browser_item.dart';

class SettingsBrowserBlock extends HookWidget {
  const SettingsBrowserBlock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String termsOfServiceURL = "https://www.zegocloud"
        ".com/policy?index=1";
    const String privacyPolicyURL = "https://www.zegocloud"
        ".com/policy?index=0";

    return Column(
      children: [
        SettingsBrowserItem(
            text: AppLocalizations.of(context)!.settingPageTermsOfService,
            targetURL: termsOfServiceURL),
        SettingsBrowserItem(
            text: AppLocalizations.of(context)!.settingPagePrivacyPolicy,
            targetURL: privacyPolicyURL),
      ]
          .map((e) => Padding(
                child: e,
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ))
          .toList(),
    );
  }
}
