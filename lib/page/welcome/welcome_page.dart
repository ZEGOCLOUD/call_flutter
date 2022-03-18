import 'package:flutter/material.dart';
import 'package:zego_call_flutter/page/welcome/welcome_title_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/common/style/styles.dart';

class ProfilePage extends StatelessWidget {
  // ignore: public_member_api_docs
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  WelcomeTitleBar(),
                  SizedBox(
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
                          const Image(
                              image:
                                  AssetImage(StyleIconUrls.welcomeCardBanner)),
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
                                  style: TextStyle(
                                      fontSize: 36.sp, color: Colors.white),
                                ),
                                Flexible(
                                  child: Text(
                                    'Deliver exceptional real-time voice and video communications regardless of distance',
                                    style: TextStyle(
                                        fontSize: 20.sp, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Contact us button
                      Container(
                        width: 320.w,
                        height: 98.h,
                        decoration: const BoxDecoration(
                          color: Color(0xffF3F4F7),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Image(
                              image: AssetImage(StyleIconUrls.welcomeContactUs),
                            ),
                            TextButton(
                                onPressed: () {
                                  // TODO jump to contact us
                                },
                                child: const Text(
                                  'Contact us',
                                  style: TextStyle(color: Color(0xff2A2A2A)),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      // Get more button
                      Container(
                        width: 320.w,
                        height: 98.h,
                        decoration: const BoxDecoration(
                          color: Color(0xffF3F4F7),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Image(
                              image: AssetImage(StyleIconUrls.welcomeGetMore),
                            ),
                            TextButton(
                                onPressed: () {
                                  // TODO jump to contact us
                                },
                                child: const Text(
                                  'Get more',
                                  style: TextStyle(color: Color(0xff2A2A2A)),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 96.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
