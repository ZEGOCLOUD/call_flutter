import '../../../zegocall/core/model/zego_user_info.dart';
import '../../../zegocall/core/zego_call_defines.dart';

class ZegoOverlayPageDelegatePageNotifier {
  Function(ZegoUserInfo info, ZegoCallType type)? onPageReceiveCallInvite;

  Function(ZegoUserInfo info)? onPageReceiveCallCanceled;

  Function(ZegoUserInfo info)? onPageReceiveCallAccept;

  Function(ZegoUserInfo info, ZegoDeclineType type)? onPageReceiveCallDecline;

  Function()? onPageReceiveCallEnded;

  Function(ZegoUserInfo info, ZegoCallTimeoutType type)?
      onPageReceiveCallTimeout;
}
