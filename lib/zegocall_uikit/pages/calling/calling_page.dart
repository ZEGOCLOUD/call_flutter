// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Project imports:
import '../../core/manager/zego_call_manager.dart';
import './../../../zegocall/core/manager/zego_service_manager.dart';
import './../../../zegocall/core/model/zego_user_info.dart';
import './../../../zegocall/core/zego_call_defines.dart';
import './../../core/machine/calling_machine.dart';
import 'calling_callee_view.dart';
import 'calling_caller_view.dart';
import 'online_video_view.dart';
import 'online_voice_view.dart';

class CallingPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CallingPage({
    Key? key,
  }) : super(key: key);

  @override
  _CallingPageState createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  CallingState currentState = CallingState.kIdle;

  final CallingMachine machine =
      ZegoCallManager.shared.pageHandler.callingMachine;

  ZegoUserInfo caller = ZegoCallManager.shared.caller ?? ZegoUserInfo.empty();
  ZegoUserInfo callee = ZegoCallManager.shared.callee ?? ZegoUserInfo.empty();
  ZegoCallType callType = ZegoCallManager.shared.currentCallType;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.onStateChanged = (CallingState state) {
        setState(() {
          caller = ZegoCallManager.shared.caller ?? ZegoUserInfo.empty();
          callee = ZegoCallManager.shared.callee ?? ZegoUserInfo.empty();
          callType = ZegoCallManager.shared.currentCallType;

          currentState = state;
        });
      };

      if (null != machine.machine.current) {
        machine.onStateChanged!(machine.machine.current!.identifier);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    machine.onStateChanged = null;
  }

  @override
  Widget build(BuildContext context) {
    var localUserInfo = ZegoServiceManager.shared.userService.localUserInfo;
    var localUser = caller.userID == localUserInfo.userID ? caller : callee;
    var remoteUser = caller.userID != localUserInfo.userID ? caller : callee;

    switch (currentState) {
      case CallingState.kIdle:
        return const SizedBox();
      case CallingState.kCallingWithVoice:
      case CallingState.kCallingWithVideo:
        var localUserIsCaller = localUserInfo.userID == caller.userID;
        var callType = currentState == CallingState.kCallingWithVideo
            ? ZegoCallType.kZegoCallTypeVideo
            : ZegoCallType.kZegoCallTypeVoice;
        return localUserIsCaller
            ? CallingCallerView(
                caller: caller, callee: callee, callType: callType)
            : CallingCalleeView(
                caller: caller, callee: callee, callType: callType);
      case CallingState.kOnlineVoice:
        return OnlineVoiceView(localUser: localUser, remoteUser: remoteUser);
      case CallingState.kOnlineVideo:
        return OnlineVideoView(localUser: localUser, remoteUser: remoteUser);
    }
  }
}
