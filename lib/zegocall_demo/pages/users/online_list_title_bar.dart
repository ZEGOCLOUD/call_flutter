// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../../utils/styles.dart';

class OnlineListTitleBar extends StatelessWidget {
  const OnlineListTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 32.w),
        height: 78.h,
        width: double.infinity,
        child: Row(children: [
          Text(AppLocalizations.of(context)!.online,
              style: StyleConstant.userListTitle),
        ]));
  }
}
