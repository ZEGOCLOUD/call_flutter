// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../../../utils/styles.dart';
import './../../../../utils/widgets/show_bottom_sheet.dart';

class OnlineTopToolBar extends StatefulWidget {
  final Widget settingWidget;
  final double settingWidgetHeight;

  const OnlineTopToolBar(
      {required this.settingWidget,
      required this.settingWidgetHeight,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OnlineTopToolBarState();
  }
}

class OnlineTopToolBarState extends State<OnlineTopToolBar> {
  final Stream<String> timerStream =
      Stream.periodic(const Duration(seconds: 1), (int count) {
    var duration = Duration(seconds: count);
    var minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    var seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return minutes + ":" + seconds;
  });

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
              //  todo
            },
            child: SizedBox(
              width: 44.w,
              child: Image.asset(StyleIconUrls.toolbarTopMini),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
              child: StreamBuilder<String>(
                  stream: timerStream, //
                  //initialData: ,// a Stream<int> or null
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasError) return const Text('');
                    if (ConnectionState.active == snapshot.connectionState) {
                      return Text(
                        snapshot.data!,
                        textAlign: TextAlign.center,
                        style: StyleConstant.onlineCountDown,
                      );
                    }
                    return const Text('');
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
