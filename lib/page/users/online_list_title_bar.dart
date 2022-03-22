import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:zego_call_flutter/common/style/styles.dart';
import 'package:zego_call_flutter/service/zego_user_service.dart';

class OnlineListTitleBar extends StatelessWidget {
  const OnlineListTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 32.w),
        height: 78.h,
        width: double.infinity,
        child: Row(children: const [
          Text('Online', style: StyleConstant.userListTitle),
        ]));
  }
}
