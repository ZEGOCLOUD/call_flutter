// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Project imports:
import './../../../zegocall/core/manager/zego_service_manager.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../../core/zego_call_manager.dart';
import './../core/machine/calling_machine.dart';
import 'calling_callee_view.dart';
import 'calling_caller_view.dart';
import 'online_video_view.dart';
import 'online_voice_view.dart';

class CallingPage extends StatefulWidget {
  // ignore: public_member_api_docs
  CallingPage({
    Key? key,
  }) : super(key: key);

  final CallingMachine machine =
      ZegoCallManager.shared.pageHandler.callingMachine;

  @override
  _CallingPageState createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  CallingState currentState = CallingState.kIdle;

  late ZegoUserInfo caller;
  late ZegoUserInfo callee;
  ZegoCallType callType = ZegoCallType.kZegoCallTypeVoice;

  @override
  void initState() {
    super.initState();

    caller = ZegoCallManager.shared.caller ?? ZegoUserInfo.empty();
    callee = ZegoCallManager.shared.callee ?? ZegoUserInfo.empty();
    callType = ZegoCallManager.shared.currentCallType;

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      widget.machine.onStateChanged = (CallingState state) {
        setState(() => currentState = state);
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    var localUser = ZegoServiceManager.shared.userService.localUserInfo;
    switch (currentState) {
      case CallingState.kIdle:
        return const SizedBox();
      case CallingState.kCallingWithVoice:
      case CallingState.kCallingWithVideo:
        var localUserIsCaller = localUser.userID == caller.userID;
        var callType = currentState == CallingState.kCallingWithVideo
            ? ZegoCallType.kZegoCallTypeVideo
            : ZegoCallType.kZegoCallTypeVoice;
        return localUserIsCaller
            ? CallingCallerView(
                caller: caller, callee: callee, callType: callType)
            : CallingCalleeView(
                caller: caller, callee: callee, callType: callType);
      case CallingState.kOnlineVoice:
        return OnlineVoiceView(caller: caller, callee: callee);
      case CallingState.kOnlineVideo:
        return OnlineVideoView(caller: caller, callee: callee);
    }
  }
}
