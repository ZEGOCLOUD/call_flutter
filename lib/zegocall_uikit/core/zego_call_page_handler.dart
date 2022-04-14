// Project imports:
import '../../zegocall/core/delegate/zego_call_service_delegate.dart';
import '../../zegocall/core/model/zego_user_info.dart';
import '../../zegocall/core/zego_call_defines.dart';
import 'machine/calling_machine.dart';
import 'machine/mini_overlay_machine.dart';
import 'manager/zego_call_manager.dart';
import 'manager/zego_call_manager_interface.dart';
import 'zego_call_page_defines.dart';

class ZegoCallPageHandler with ZegoCallServiceDelegate {
  late CallingMachine callingMachine;
  late MiniOverlayMachine miniOverlayMachine;
  ZegoCallPageType currentPageType = ZegoCallPageType.none;

  void init() {
    callingMachine = CallingMachine();
    callingMachine.init();

    miniOverlayMachine = MiniOverlayMachine();
    miniOverlayMachine.init();
  }

  void restoreToIdle() {
    callingMachine.stateIdle.enter();
    miniOverlayMachine.stateIdle.enter();

    currentPageType = ZegoCallPageType.none;
  }

  void onCallUserExecuted(int errorCode) {
    var callType = ZegoCallManager.shared.currentCallType;

    if (ZegoError.success.id == errorCode) {
      if (ZegoCallType.kZegoCallTypeVoice == callType) {
        callingMachine.stateCallingWithVoice.enter();
      } else {
        callingMachine.stateCallingWithVideo.enter();
      }

      currentPageType = ZegoCallPageType.callingPage;
    } else {
      restoreToIdle();
    }
  }

  void onAcceptCallWillExecute() {
    var callType = ZegoCallManager.shared.currentCallType;

    if (ZegoCallType.kZegoCallTypeVoice == callType) {
      callingMachine.stateCallingWithVoice.enter();
    } else {
      callingMachine.stateCallingWithVideo.enter();
    }

    currentPageType = ZegoCallPageType.callingPage;
  }

  void onAcceptCallExecuted(int errorCode) {
    var callType = ZegoCallManager.shared.currentCallType;

    if (ZegoError.success.id == errorCode) {
      if (ZegoCallType.kZegoCallTypeVoice == callType) {
        callingMachine.stateOnlineVoice.enter();
      } else {
        callingMachine.stateOnlineVideo.enter();
      }

      currentPageType = ZegoCallPageType.callingPage;
    } else {
      restoreToIdle();
    }
  }

  void onDeclineCallExecuted() {
    var callType = ZegoCallManager.shared.currentCallType;

    // miniOverlayMachine.voiceCallingOverlayMachine.stateDeclined.enter();

    restoreToIdle();
  }

  void onEndCallExecuted() {
    var callType = ZegoCallManager.shared.currentCallType;

    miniOverlayMachine.voiceCallingOverlayMachine.stateEnded.enter();

    restoreToIdle();
  }

  void onCancelCallExecuted() {
    var callType = ZegoCallManager.shared.currentCallType;

    restoreToIdle();
  }

  @override
  void onCallingStateUpdated(ZegoCallingState state) {
    // TODO: implement onCallingStateUpdated
  }

  @override
  void onReceiveCallAccepted(ZegoUserInfo callee) {
    var callType = ZegoCallManager.shared.currentCallType;

    switch (currentPageType) {
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
          miniOverlayMachine.videoCallingOverlayMachine.stateOnlyCallerWithVideo
              .enter();
        }
        break;
      default:
        break;
    }
  }

  @override
  void onReceiveCallCanceled(ZegoUserInfo caller) {
    switch (currentPageType) {
      case ZegoCallPageType.callingPage:
        callingMachine.stateIdle.enter();
        break;
      case ZegoCallPageType.invitePage:
        // TODO: Handle this case.
        break;
      case ZegoCallPageType.miniPage:
        miniOverlayMachine.stateIdle.enter();
        break;
      default:
        break;
    }
  }

  @override
  void onReceiveCallDecline(ZegoUserInfo callee, ZegoDeclineType type) {
    switch (currentPageType) {
      case ZegoCallPageType.callingPage:
        callingMachine.stateIdle.enter();
        break;
      case ZegoCallPageType.invitePage:
        break;
      case ZegoCallPageType.miniPage:
        miniOverlayMachine.stateIdle.enter();
        miniOverlayMachine.voiceCallingOverlayMachine.stateDeclined.enter();
        break;
      default:
        break;
    }
  }

  @override
  void onReceiveCallEnded() {
    switch (currentPageType) {
      case ZegoCallPageType.callingPage:
        callingMachine.stateIdle.enter();
        break;
      case ZegoCallPageType.invitePage:
        break;
      case ZegoCallPageType.miniPage:
        miniOverlayMachine.voiceCallingOverlayMachine.stateEnded.enter();
        break;
      default:
        break;
    }
  }

  @override
  void onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type) {
    switch (currentPageType) {
      case ZegoCallPageType.callingPage:
        break;
      case ZegoCallPageType.invitePage:
        break;
      case ZegoCallPageType.miniPage:
        break;
      case ZegoCallPageType.none:
        currentPageType = ZegoCallPageType.invitePage;
        miniOverlayMachine.stateBeInvite.enter();
        break;
      default:
        break;
    }
  }

  void onMiniOverlayBeInvitePageEmptyClicked() {
    switch (currentPageType) {
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

        currentPageType = ZegoCallPageType.callingPage;
        break;
      case ZegoCallPageType.miniPage:
        break;
    }
  }

  @override
  void onReceiveCallTimeout(ZegoUserInfo caller, ZegoCallTimeoutType type) {
    var callStatus = ZegoCallManager.shared.currentCallStatus;

    switch (currentPageType) {
      case ZegoCallPageType.callingPage:
        callingMachine.stateIdle.enter();
        break;
      case ZegoCallPageType.invitePage:
        break;
      case ZegoCallPageType.miniPage:
        switch (type) {
          case ZegoCallTimeoutType.connecting:
            if (callStatus == ZegoCallStatus.wait ||
                callStatus == ZegoCallStatus.waitAccept) {
              miniOverlayMachine.voiceCallingOverlayMachine.stateMissed.enter();
            }
            break;
          case ZegoCallTimeoutType.calling:
            miniOverlayMachine.voiceCallingOverlayMachine.stateEnded.enter();
            break;
        }

        break;
      default:
        break;
    }
  }
}
