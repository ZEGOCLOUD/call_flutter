// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import '../styles.dart';
import 'navigation_back_bar.dart';
import 'toast_manager.dart';

class Browser extends StatefulWidget {
  const Browser({required this.url, required this.backURL, Key? key})
      : super(key: key);

  final String url;
  final String backURL;

  @override
  BrowserState createState() => BrowserState();
}

class BrowserState extends State<Browser> {
  String title = "";
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();

    ToastManager.shared.showLoading();
  }

  @override
  void dispose() {
    super.dispose();

    ToastManager.shared.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          NavigationBackBar(
              targetBackUrl: widget.backURL,
              title: title,
              titleStyle: StyleConstant.browserTitle,
              iconColor: StyleConstant.browserTitle.color),
          SizedBox(
            height: 1130.h,
            child: WebView(
                initialUrl: widget.url,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (String url) {
                  String script = 'window.document.title';
                  webViewController
                      .runJavascriptReturningResult(script)
                      .then((value) {
                    ToastManager.shared.hide();

                    setState(() {
                      title = value.replaceAll("\"", "");
                    });
                  });
                }),
          )
        ],
      ),
    ));
  }
}
