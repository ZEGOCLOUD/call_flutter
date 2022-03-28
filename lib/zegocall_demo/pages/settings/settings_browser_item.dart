import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zego_call_flutter/zegocall_demo/constants/zego_page_constant.dart';
import 'package:zego_call_flutter/utils/widgets/browser.dart';
import 'package:zego_call_flutter/utils/styles.dart';

class SettingsBrowserItem extends StatelessWidget {
  final String text;
  final String targetURL;

  const SettingsBrowserItem(
      {required this.text, required this.targetURL, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: StyleColors.settingsCellBackgroundColor,
        ),
        padding: EdgeInsets.only(left: 32.w, top: 0, right: 32.w, bottom: 0),
        child: SizedBox(
            height: 98.h,
            child: InkWell(
              onTap: () {
                launchURL(context, targetURL);
              },
              child: Row(
                children: [
                  Text(text,
                      style: StyleConstant.settingTitle,
                      textDirection: TextDirection.ltr),
                  const Expanded(
                    child: Text(''),
                  )
                ],
              ),
            )));
  }

  void launchURL(BuildContext context, String targetURL) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Browser(url: targetURL, backURL: PageRouteNames.settings);
    }));
  }
}
