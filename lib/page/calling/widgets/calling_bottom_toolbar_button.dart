import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zego_call_flutter/common/style/styles.dart';

class CallingCalleeBottomToolBarButton extends StatelessWidget {
  final String text;
  final String iconURL;
  final double iconWidth;
  final double iconHeight;
  final VoidCallback onTap;

  const CallingCalleeBottomToolBarButton(
      {this.text = "",
      required this.iconURL,
      required this.iconWidth,
      required this.iconHeight,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: iconWidth,
            height: iconHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage(iconURL),
              fit: BoxFit.fitWidth,
            )),
          ),
          text.isEmpty
              ? const SizedBox()
              : SizedBox(
                  height: 12.h,
                ),
          text.isEmpty
              ? const SizedBox()
              : Text(
                  text,
                  style: StyleConstant.callingButtonIconText,
                )
        ],
      ),
    );
  }
}
