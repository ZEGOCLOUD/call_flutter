import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallingPage extends StatelessWidget {
  // ignore: public_member_api_docs
  const CallingPage({Key? key}) : super(key: key);

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
                  const Text('Calling'),
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
