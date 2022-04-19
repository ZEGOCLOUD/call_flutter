// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Project imports:
import '../../../zegocall/core/manager/zego_service_manager.dart';
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import '../../core/machine/zego_calling_machine.dart';
import '../../core/manager/zego_call_manager.dart';
import 'zego_calling_callee_view.dart';
import 'zego_calling_caller_view.dart';
import 'zego_online_video_view.dart';
import 'zego_online_voice_view.dart';

class ZegoCallingPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const ZegoCallingPage({
    Key? key,
  }) : super(key: key);

  @override
  ZegoCallingPageState createState() => ZegoCallingPageState();
}

class ZegoCallingPageState extends State<ZegoCallingPage> {
  CallingState currentState = CallingState.kIdle;

  final ZegoCallingMachine machine =
      ZegoCallManager.shared.pageHandler.callingMachine;

  late ZegoUserInfo caller;
  late ZegoUserInfo callee;
  ZegoCallType callType = ZegoCallManager.shared.currentCallType;

  @override
  void initState() {
    super.initState();

    caller =
        ZegoCallManager.shared.getLatestUser(ZegoCallManager.shared.caller);
    callee =
        ZegoCallManager.shared.getLatestUser(ZegoCallManager.shared.callee);

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.onStateChanged = (CallingState state) {
        setState(() {
          caller = ZegoCallManager.shared
              .getLatestUser(ZegoCallManager.shared.caller);
          callee = ZegoCallManager.shared
              .getLatestUser(ZegoCallManager.shared.callee);

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
    var callID = ZegoCallManager.shared.currentCallID();
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
            ? ZegoCallingCallerView(
                caller: caller, callee: callee, callType: callType)
            : ZegoCallingCalleeView(
                caller: caller, callee: callee, callType: callType);
      case CallingState.kOnlineVoice:
        return ZegoOnlineVoiceView(
            callID: callID, localUser: localUser, remoteUser: remoteUser);
      case CallingState.kOnlineVideo:
        return ZegoOnlineVideoView(
            callID: callID, localUser: localUser, remoteUser: remoteUser);
    }
  }
}
