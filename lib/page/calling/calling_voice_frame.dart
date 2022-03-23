import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_call_flutter/page/calling/calling_control_bar.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';

class CallingVoiceFrame extends StatelessWidget {
  CallingVoiceFrame(
      {Key? key, required this.calleeName, required this.calleePhotoUrl})
      : super(key: key);

  String calleeName;
  String calleePhotoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(calleePhotoUrl),
        fit: BoxFit.fill,
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 237,
          ),
          CircleAvatar(),
          Text(calleeName),
          Text('Calling...'),
          Expanded(child: SizedBox()),
          CallingControlBarCalling(),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
