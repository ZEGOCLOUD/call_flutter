import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zego_call_flutter/common/style/styles.dart';

class NavigationBackBar extends StatelessWidget {
  final String targetBackUrl;

  const NavigationBackBar({required this.targetBackUrl, Key? key})
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
                  const Text('Back', style: StyleConstant.backText)
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
