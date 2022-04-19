// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../styles.dart';

class SettingSDKVersionItem extends StatelessWidget {
  final String title;
  final String content;

  const SettingSDKVersionItem(
      {required this.title, required this.content, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: body(context),
    );
  }

  Widget body(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: StyleColors.settingsCellBackgroundColor,
        ),
        padding: EdgeInsets.only(left: 32.w, top: 0, right: 32.w, bottom: 0),
        child: SizedBox(
            height: 98.h,
            child: Row(children: [
              Text(title,
                  style: StyleConstant.settingTitle,
                  textDirection: TextDirection.ltr),
              const Expanded(
                child: Text(''),
              ),
              Text(content,
                  style: StyleConstant.settingVersion,
                  textDirection: TextDirection.rtl)
            ])));
  }
}
