// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../constants/page_constant.dart';
import '../../styles.dart';
import '../../widgets/browser.dart';

class WelcomeToolBarButton extends StatelessWidget {
  final String iconAssetName;
  final String text;

  const WelcomeToolBarButton(
      {required this.iconAssetName, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: AssetImage(iconAssetName),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Color(0xff2A2A2A)),
          ),
        ],
      ),
    );
  }
}

class WelcomeToolBar extends StatelessWidget {
  const WelcomeToolBar({Key? key}) : super(key: key);
  final String getMoreURL = "https://www.zegocloud.com/";
  final String contactUSURL = "https://www.zegocloud.com/talk";

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: GestureDetector(
            child: WelcomeToolBarButton(
                iconAssetName: StyleIconUrls.welcomeContactUs,
                text: AppLocalizations.of(context)!.welcomePageContactUs),
            onTap: () {
              launchURL(context, contactUSURL);
            },
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
          child: GestureDetector(
            child: WelcomeToolBarButton(
                iconAssetName: StyleIconUrls.welcomeGetMore,
                text: AppLocalizations.of(context)!.welcomePageGetMore),
            onTap: () {
              launchURL(context, getMoreURL);
            },
          ),
        ),
      ],
    );
  }

  void launchURL(BuildContext context, String targetURL) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Browser(url: targetURL, backURL: PageRouteNames.welcome);
    }));
  }
}
