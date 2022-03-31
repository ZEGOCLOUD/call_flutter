// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import './../styles.dart';
import 'navigation_back_bar.dart';

class Browser extends HookWidget {
  final String url;
  final String backURL;
  late WebViewController webViewController;

  Browser({required this.url, required this.backURL, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var title = useState('');

    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          NavigationBackBar(
              targetBackUrl: backURL,
              title: title.value,
              titleStyle: StyleConstant.browserTitle,
              iconColor: StyleConstant.browserTitle.color),
          SizedBox(
            height: 1130.h,
            child: WebView(
                initialUrl: url,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (String url) {
                  String script = 'window.document.title';
                  webViewController.runJavascriptReturningResult(script).then(
                      (value) => title.value = value.replaceAll("\"", ""));
                }),
          )
        ],
      ),
    ));
  }
}
