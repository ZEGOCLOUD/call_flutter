// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall_uikit/core/manager/zego_call_manager.dart';
import './../../../../utils/styles.dart';
import './../../../../utils/widgets/show_bottom_sheet.dart';

class OnlineTopToolBar extends StatefulWidget {
  final String callID;
  final Widget settingWidget;
  final double settingWidgetHeight;

  const OnlineTopToolBar(
      {required this.callID,
      required this.settingWidget,
      required this.settingWidgetHeight,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OnlineTopToolBarState();
  }
}

class OnlineTopToolBarState extends State<OnlineTopToolBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      //test
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
      ),
      padding: EdgeInsets.only(left: 36.w, right: 36.w),
      height: 88.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              ZegoCallManager.shared.onMiniOverlayRequest();
            },
            child: SizedBox(
              width: 44.w,
              child: Image.asset(StyleIconUrls.toolbarTopMini),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
              child: ValueListenableBuilder<String>(
                  valueListenable: ZegoCallManager.shared.callTimeManager
                      .startTimer(widget.callID)
                      .formatCallTimeNotifier,
                  builder: (context, formatCallingTime, _) {
                    return Text(formatCallingTime,
                        textAlign: TextAlign.center,
                        style: StyleConstant.onlineCountDown);
                  })),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              showModalBottomSheetWithStyle(
                  context, widget.settingWidgetHeight, widget.settingWidget);
            },
            child: SizedBox(
              width: 44.w,
              child: Image.asset(StyleIconUrls.toolbarTopSettings),
            ),
          )
        ],
      ),
    ));
  }
}
