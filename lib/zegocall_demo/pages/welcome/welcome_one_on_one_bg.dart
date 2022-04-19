// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../styles.dart';
import './../../constants/page_constant.dart';

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
                        AppLocalizations.of(context)!.bannerCallTitle,
                        style: TextStyle(fontSize: 36.sp, color: Colors.white),
                      ),
                      Flexible(
                        child: Text(
                            AppLocalizations.of(context)!.bannerCallDesc,
                            style: TextStyle(
                                fontSize: 20.sp, color: Colors.white)),
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
