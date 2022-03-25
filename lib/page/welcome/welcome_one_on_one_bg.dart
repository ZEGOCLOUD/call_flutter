import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:zego_call_flutter/common/style/styles.dart';

import 'package:zego_call_flutter/constants/zego_page_constant.dart';
import 'package:zego_call_flutter/service/zego_user_service.dart';

class WelcomeOneOnOneBg extends StatelessWidget {
  const WelcomeOneOnOneBg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: SizedBox(
          height: 280.h,
          width: 686.w,
          child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage(StyleIconUrls.welcomeCardBg),
              fit: BoxFit.fill,
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Image(image: AssetImage(StyleIconUrls.welcomeCardBanner)),
                SizedBox(
                  width: 20.w,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 321.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 67.h,
                      ),
                      Text(
                        'One-On-One Call',
                        style: TextStyle(fontSize: 36.sp, color: Colors.white),
                      ),
                      Flexible(
                        child: Text(
                          'Deliver exceptional real-time voice and video communications regardless of distance',
                          style:
                              TextStyle(fontSize: 20.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.pushReplacementNamed(context, PageRouteNames.onlineList);
        });
  }
}
