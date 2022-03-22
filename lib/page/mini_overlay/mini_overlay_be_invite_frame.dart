import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../service/zego_call_service.dart';

class MiniOverlayBeInviteFrame extends StatefulWidget {
  MiniOverlayBeInviteFrame(
      {Key? key,
      required this.callerName,
      required this.callerID,
      required this.callType,
      required this.onDecline,
      required this.onAccept})
      : super(key: key);

  String callerID;
  String callerName;
  ZegoCallType callType;
  VoidCallback onDecline;
  VoidCallback onAccept;

  @override
  _MiniOverlayBeInviteFrame createState() => _MiniOverlayBeInviteFrame();
}

class _MiniOverlayBeInviteFrame extends State<MiniOverlayBeInviteFrame> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 100,
      child: Row(
        children: [
          Container(
            color: Colors.red,
            width: 150,
            height: 50,
            child: Column(
              children: [
                Text('${widget.callerName}'),
                Text('${widget.callType}'),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
          // TODO get token
          TextButton(
              onPressed: () {
                context.read<ZegoCallService>().respondCall(widget.callerID,
                    'token', ZegoResponseType.kZegoResponseTypeDecline);
                widget.onDecline();
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                context.read<ZegoCallService>().respondCall(widget.callerID,
                    'token', ZegoResponseType.kZegoResponseTypeAccept);
                widget.onAccept();
              },
              child: const Text('Cancel')),
        ],
      ),
    );
  }
}
