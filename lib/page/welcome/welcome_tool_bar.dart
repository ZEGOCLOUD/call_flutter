import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/common/style/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../service/zego_user_service.dart';
import '../broswer.dart';

class WelcomeToolBarButton extends StatelessWidget {
  final String iconAssetName;
  final String text;

  const WelcomeToolBarButton(
      {required this.iconAssetName, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
            child: const WelcomeToolBarButton(
                iconAssetName: StyleIconUrls.welcomeContactUs,
                text: 'Contact us'),
            onTap: () {
              _launchURL(context, contactUSURL);
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
            child: const WelcomeToolBarButton(
                iconAssetName: StyleIconUrls.welcomeGetMore, text: 'Get more'),
            onTap: () {
              _launchURL(context, getMoreURL);
            },
          ),
        ),
      ],
    );
  }

  void _launchURL(BuildContext context, String targetURL) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Browser(url: targetURL);
    }));
  }
}
