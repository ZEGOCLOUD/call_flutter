import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zego_call_flutter/common/style/styles.dart';

class NavigationBackBar extends HookWidget {
  final String targetBackUrl;
  String title;

  NavigationBackBar(
      {required this.targetBackUrl, this.title = "Back", Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 750.w,
      height: 88.h,
      child: Row(
        children: [
          GestureDetector(
              child: Row(
                children: [
                  Image(
                      image: const AssetImage(StyleIconUrls.navigatorBack),
                      width: 88.w),
                  SizedBox(width: 5.w),
                  SizedBox(
                    width: 655.w,
                    child: Text(title,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: StyleConstant.backText),
                  )
                ],
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, targetBackUrl);
              }),
          const Expanded(child: Text('')),
        ],
      ),
    );
  }
}
