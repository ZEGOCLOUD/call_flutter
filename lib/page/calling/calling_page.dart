import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallingPage extends StatelessWidget {
  // ignore: public_member_api_docs
  const CallingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationPayload =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    print(notificationPayload);
    var callerName = notificationPayload['caller_name']!;

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
                  Text("$callerName Calling you"),
                  const Expanded(child: SizedBox()),
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
