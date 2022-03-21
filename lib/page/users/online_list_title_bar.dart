import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zego_call_flutter/common/style/styles.dart';

class OnlineListTitleBar extends StatelessWidget {
  const OnlineListTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 32.w),
        height: 78.h,
        width: double.infinity,
        child: Row(children: const [
          Text('Online', style: StyleConstant.userListTitle)
        ]));
  }
}