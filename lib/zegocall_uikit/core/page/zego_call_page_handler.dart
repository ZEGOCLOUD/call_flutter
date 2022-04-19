// Dart imports:
import 'dart:async';

// Project imports:
import 'package:zego_call_flutter/zegocall_uikit/utils/zego_loading_manager.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';

import '../../../logger.dart';
import '../../../zegocall/core/delegate/zego_call_service_delegate.dart';
import '../../../zegocall/core/manager/zego_service_manager.dart';
import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';
import '../../../zegocall_demo/pages/navigation_service.dart';
import '../machine/zego_calling_machine.dart';
import '../machine/zego_mini_overlay_machine.dart';
import '../manager/zego_call_manager.dart';
import '../manager/zego_call_manager_interface.dart';

enum ZegoCallPageType {
  none,
  callingPage,
  invitePage,
  miniPage,
}

class ZegoCallPageHandler with ZegoCallServiceDelegate {
  late ZegoCallingMachine callingMachine;
  late ZegoMiniOverlayMachine miniOverlayMachine;

  ZegoCallingState callingState = ZegoCallingState.connected;

  void init() {
    callingMachine = ZegoCallingMachine();
    callingMachine.init();

    miniOverlayMachine = ZegoMiniOverlayMachine();
    miniOverlayMachine.init();
  }

  void restoreToIdle() {
    debugCurrentMachineState();

    if (CallingState.kIdle !=
        (callingMachine.machine.current?.identifier ?? CallingState.kIdle)) {
      callingMachine.stateIdle.enter();
    }

    if (MiniOverlayPageState.kIdle !=
        (miniOverlayMachine.machine.current?.identifier ??
            MiniOverlayPageState.kIdle)) {
      miniOverlayMachine.stateIdle.enter();
    }
  }

  void debugCurrentMachineState() {
    var callingState = callingMachine.getPageState();
    var miniOverlayState = miniOverlayMachine.getPageState();
    logInfo(
        'calling state:$callingState, mini overlay state:$miniOverlayState');
  }

  ZegoCallPageType currentPageType() {
    var callingState = callingMachine.getPageState();
    var miniOverlayState = miniOverlayMachine.getPageState();

    if (MiniOverlayPageState.kBeInvite == miniOverlayState) {
      return ZegoCallPageType.invitePage;
    } else if (MiniOverlayPageState.kVoiceCalling == miniOverlayState ||
        MiniOverlayPageState.kVideoCalling == miniOverlayState) {
      return ZegoCallPageType.miniPage;
    }

    if (CallingState.kIdle != callingState) {
      return ZegoCallPageType.callingPage;
    }

    return ZegoCallPageType.none;
  }

  void onCallUserExecuted(int errorCode) {
    var callType = ZegoCallManager.shared.currentCallType;

    if (ZegoError.success.id == errorCode) {
      if (ZegoCallType.kZegoCallTypeVoice == callType) {
        callingMachine.stateCallingWithVoice.enter();
      } else {
        callingMachine.stateCallingWithVideo.enter();
      }
    } else {
      restoreToIdle();
    }
  }

  void onAcceptCallWillExecute() {
    var callType = ZegoCallManager.shared.currentCallType;

    if (ZegoCallPageType.invitePage == currentPageType()) {
      miniOverlayMachine.stateIdle.enter(); //  hide if from invite overlay
    }

    if (ZegoCallType.kZegoCallTypeVoice == callType) {
      callingMachine.stateCallingWithVoice.enter();
    } else {
      callingMachine.stateCallingWithVideo.enter();
    }
  }

  void onAcceptCallExecuted(int errorCode) {
    var callType = ZegoCallManager.shared.currentCallType;

    if (ZegoError.success.id == errorCode) {
      if (ZegoCallType.kZegoCallTypeVoice == callType) {
        callingMachine.stateOnlineVoice.enter();
      } else {
        callingMachine.stateOnlineVideo.enter();
      }
    } else {
      restoreToIdle();
    }
  }

  void onDeclineCallExecuted() {
    if (ZegoCallPageType.miniPage == currentPageType()) {
      var callType = ZegoCallManager.shared.currentCallType;
      if (ZegoCallType.kZegoCallTypeVoice == callType) {
        miniOverlayMachine.voiceCallingOverlayMachine.stateDeclined.enter();
      } else {
        miniOverlayMachine.videoCallingOverlayMachine.stateIdle.enter();
      }
    } else {
      restoreToIdle();
    }
  }

  void onEndCallExecuted() {
    if (ZegoCallPageType.miniPage == currentPageType()) {
      var callType = ZegoCallManager.shared.currentCallType;
      if (ZegoCallType.kZegoCallTypeVoice == callType) {
        miniOverlayMachine.voiceCallingOverlayMachine.stateEnded.enter();
      } else {
        miniOverlayMachine.videoCallingOverlayMachine.stateIdle.enter();
      }
    } else {
      restoreToIdle();
    }
  }

  void onCancelCallExecuted() {
    restoreToIdle();
  }

  @override
  void onCallingStateUpdated(ZegoCallingState state) {
    logInfo("state:$state");

    callingState = state;

    final NavigationService _navigationService = locator<NavigationService>();
    var context = _navigationService.navigatorKey.currentContext!;

    switch (state) {
      case ZegoCallingState.disconnected:
      case ZegoCallingState.connected:
        ZegoToastManager.shared.hide();
        break;
      case ZegoCallingState.connecting:
        ZegoToastManager.shared.showLoading(
            message: AppLocalizations.of(context)!.callPageCallDisconnected);
        break;
    }
  }

  @override
  void onReceiveCallAccepted(ZegoUserInfo callee) {
    var callType = ZegoCallManager.shared.currentCallType;

    switch (currentPageType()) {
      case ZegoCallPageType.callingPage:
        if (ZegoCallType.kZegoCallTypeVoice == callType) {
          callingMachine.stateOnlineVoice.enter();
        } else {
          callingMachine.stateOnlineVideo.enter();
        }
        break;
      case ZegoCallPageType.invitePage:
        // TODO: Handle this case.
        break;
      case ZegoCallPageType.miniPage:
        if (ZegoCallType.kZegoCallTypeVoice == callType) {
          miniOverlayMachine.voiceCallingOverlayMachine.stateOnline.enter();
        } else {
          miniOverlayMachine.videoCallingOverlayMachine.stateLocalUserWithVideo
              .enter();
        }
        break;
      default:
        break;
    }
  }

  @override
  void onReceiveCallCanceled(ZegoUserInfo caller) {
    restoreToIdle();
  }

  @override
  void onReceiveCallDecline(ZegoUserInfo callee, ZegoDeclineType type) {
    switch (currentPageType()) {
      case ZegoCallPageType.callingPage:
        callingMachine.stateIdle.enter();
        break;
      case ZegoCallPageType.invitePage:
        break;
      case ZegoCallPageType.miniPage:
        if (MiniOverlayPageState.kVoiceCalling ==
            miniOverlayMachine.getPageState()) {
          miniOverlayMachine.voiceCallingOverlayMachine.stateDeclined.enter();
        } else {
          miniOverlayMachine.stateIdle.enter();
        }
        break;
      default:
        break;
    }
  }

  @override
  void onReceiveCallEnded() {
    switch (currentPageType()) {
      case ZegoCallPageType.callingPage:
        callingMachine.stateIdle.enter();
        break;
      case ZegoCallPageType.invitePage:
        break;
      case ZegoCallPageType.miniPage:
        if (MiniOverlayPageState.kVoiceCalling ==
            miniOverlayMachine.getPageState()) {
          miniOverlayMachine.voiceCallingOverlayMachine.stateEnded.enter();
        } else {
          miniOverlayMachine.stateIdle.enter();
        }
        break;
      default:
        break;
    }
  }

  @override
  void onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type) {
    switch (currentPageType()) {
      case ZegoCallPageType.callingPage:
        break;
      case ZegoCallPageType.invitePage:
        break;
      case ZegoCallPageType.miniPage:
        break;
      case ZegoCallPageType.none:
        miniOverlayMachine.stateBeInvite.enter();
        break;
      default:
        break;
    }
  }

  void onMiniOverlayBeInvitePageEmptyClicked() {
    switch (currentPageType()) {
      case ZegoCallPageType.none:
        break;
      case ZegoCallPageType.callingPage:
        break;
      case ZegoCallPageType.invitePage:
        miniOverlayMachine.stateIdle.enter();

        var callType = ZegoCallManager.shared.currentCallType;
        if (ZegoCallType.kZegoCallTypeVoice == callType) {
          callingMachine.stateCallingWithVoice.enter();
        } else {
          callingMachine.stateCallingWithVideo.enter();
        }
        break;
      case ZegoCallPageType.miniPage:
        break;
    }
  }

  void onMiniOverlayRequest() {
    logInfo('request');

    var callType = ZegoCallManager.shared.currentCallType;
    if (ZegoCallType.kZegoCallTypeVoice == callType) {
      enterMiniVoiceMachine();
    } else {
      enterMiniVideoMachine();
    }
  }

  void enterMiniVoiceMachine() {
    miniOverlayMachine.stateVoiceCalling.enter();

    var voiceMachine = miniOverlayMachine.voiceCallingOverlayMachine;
    switch (ZegoCallManager.shared.currentCallStatus) {
      case ZegoCallStatus.free:
      case ZegoCallStatus.wait:
        voiceMachine.stateWaiting.enter();
        break;
      case ZegoCallStatus.waitAccept:
      case ZegoCallStatus.calling:
        voiceMachine.stateOnline.enter();
        break;
    }
  }

  void enterMiniVideoMachine() {
    miniOverlayMachine.stateVideoCalling.enter();

    var userService = ZegoServiceManager.shared.userService;
    var localUser = userService.localUserInfo;
    var remoteUser = localUser.userID == ZegoCallManager.shared.caller.userID
        ? ZegoCallManager.shared.getLatestUser(ZegoCallManager.shared.callee)
        : ZegoCallManager.shared.getLatestUser(ZegoCallManager.shared.caller);

    if (remoteUser.camera) {
      miniOverlayMachine.videoCallingOverlayMachine.stateRemoteUserWithVideo
          .enter();
    } else if (localUser.camera) {
      miniOverlayMachine.videoCallingOverlayMachine.stateLocalUserWithVideo
          .enter();
    } else {
      //  turn to mini voice
      enterMiniVoiceMachine();
    }
  }

  void onMiniOverlayRestore() {
    logInfo('restore');

    miniOverlayMachine.stateIdle.enter();

    var callType = ZegoCallManager.shared.currentCallType;
    if (ZegoCallType.kZegoCallTypeVoice == callType) {
      callingMachine.stateOnlineVoice.enter();
    } else {
      callingMachine.stateOnlineVideo.enter();
    }
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo caller, ZegoCallTimeoutType type) {
    var callStatus = ZegoCallManager.shared.currentCallStatus;

    switch (currentPageType()) {
      case ZegoCallPageType.callingPage:
        callingMachine.stateIdle.enter();
        break;
      case ZegoCallPageType.invitePage:
        break;
      case ZegoCallPageType.miniPage:
        if (MiniOverlayPageState.kVoiceCalling ==
            miniOverlayMachine.getPageState()) {
          switch (type) {
            case ZegoCallTimeoutType.connecting:
              if (callStatus == ZegoCallStatus.wait ||
                  callStatus == ZegoCallStatus.waitAccept) {
                miniOverlayMachine.voiceCallingOverlayMachine.stateMissed
                    .enter();
              }
              break;
            case ZegoCallTimeoutType.calling:
              miniOverlayMachine.voiceCallingOverlayMachine.stateEnded.enter();
              break;
          }
        } else {
          miniOverlayMachine.stateIdle.enter();
        }
        break;
      default:
        break;
    }
  }

  void onUserInfoUpdate(ZegoUserInfo info) {
    var miniPageState = miniOverlayMachine.getPageState();
    var isMiniOnline = MiniOverlayPageState.kVoiceCalling == miniPageState ||
        MiniOverlayPageState.kVideoCalling == miniPageState;

    var callType = ZegoCallManager.shared.currentCallType;
    if (isMiniOnline && ZegoCallType.kZegoCallTypeVideo == callType) {
      if (MiniOverlayPageState.kVideoCalling == miniPageState) {
        //  video switch to other user
        miniOverlayMachine.stateIdle.enter();

        Timer(const Duration(milliseconds: 100), () {
          //  todo,  need to wait for a while; otherwise, the view is not
          //   match the state
          enterMiniVideoMachine();
        });
      } else {
        //  voice restore to video, because current voice state is switched from
        //  video before
        enterMiniVideoMachine();
      }
    }
  }
}
