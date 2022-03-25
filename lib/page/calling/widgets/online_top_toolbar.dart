import 'package:flutter/material.dart';

import 'package:zego_call_flutter/common/style/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnlineTopToolBar extends StatefulWidget {
  const OnlineTopToolBar({Key? key}) : super(key: key);

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
              //  todo
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
