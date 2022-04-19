// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../styles.dart';

class NavigationBackBar extends HookWidget {
  final String targetBackUrl;

  final Color? iconColor;

  final String title;
  final TextAlign titleAlign;
  final TextStyle titleStyle;

  const NavigationBackBar(
      {required this.targetBackUrl,
      required this.titleStyle,
      this.iconColor,
      this.title = "Back",
      this.titleAlign = TextAlign.left,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 750.w,
        height: 88.h,
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, targetBackUrl);
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image(
                  image: const AssetImage(StyleIconUrls.navigatorBack),
                  width: 88.w,
                  color: iconColor),
              TextAlign.center == titleAlign
                  ? const Expanded(child: Text(''))
                  : const Text(''),
              Text(title,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle),
              TextAlign.center == titleAlign
                  ? const Expanded(child: Text(''))
                  : const Text(''),
              TextAlign.center == titleAlign
                  ? SizedBox(width: 88.w)
                  : const Text('')
            ],
          ),
        ));
  }
}
