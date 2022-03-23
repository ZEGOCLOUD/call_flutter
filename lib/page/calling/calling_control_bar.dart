import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../service/zego_call_service.dart';

class CallingControlBarCalling extends StatelessWidget {
  CallingControlBarCalling({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: TextButton(
          onPressed: () {
            context.read<ZegoCallService>().cancelCall();
          },
          child: Text('Cancel'),
        ),
      ),
    );
  }
}

class CallingControlBarOnlineVoice extends StatelessWidget {
  CallingControlBarOnlineVoice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 300,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO toggle mic
              },
              child: Text('Mic'),
            ),
            TextButton(
              onPressed: () {
                context.read<ZegoCallService>().endCall();
              },
              child: Text('End'),
            ),
            TextButton(
              onPressed: () {
                // TODO toggle speaker
              },
              child: Text('Speaker'),
            ),
          ],
        ),
      ),
    );
  }
}

class CallingControlBarOnlineVideo extends StatelessWidget {
  CallingControlBarOnlineVideo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 300,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO toggle camera
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                // TODO toggle mic
              },
              child: Text('Mic'),
            ),
            TextButton(
              onPressed: () {
                context.read<ZegoCallService>().endCall();
              },
              child: Text('End'),
            ),
            TextButton(
              onPressed: () {
                // TODO switch camera
              },
              child: Text('Switch'),
            ),
            TextButton(
              onPressed: () {
                // TODO toggle speaker
              },
              child: Text('Speaker'),
            ),
          ],
        ),
      ),
    );
  }
}
