// Package imports:
import 'package:result_type/result_type.dart';

typedef RequestResult = Result<dynamic, ZegoError>;
typedef RequestParameterType = Map<String, dynamic>;

enum ZegoCallType { kZegoCallTypeVoice, kZegoCallTypeVideo }

extension ZegoCallTypeExtension on ZegoCallType {
  int get id {
    switch (this) {
      case ZegoCallType.kZegoCallTypeVoice:
        return 1;
      case ZegoCallType.kZegoCallTypeVideo:
        return 2;
    }
  }

  static const Map<int, ZegoCallType> mapValue = {
    1: ZegoCallType.kZegoCallTypeVoice,
    2: ZegoCallType.kZegoCallTypeVideo,
  };

  String get string {
    switch (this) {
      case ZegoCallType.kZegoCallTypeVoice:
        return "voice";
      case ZegoCallType.kZegoCallTypeVideo:
        return "video";
    }
  }
}

enum ZegoCallTimeoutType {
  /// connecting: the call timed out when try to connecting.
  connecting,

  /// calling: the call timed out during a call.
  calling
}

extension ZegoCallTimeoutTypeExtension on ZegoCallTimeoutType {
  String get string {
    switch (this) {
      case ZegoCallTimeoutType.connecting:
        return "connecting";
      case ZegoCallTimeoutType.calling:
        return "calling";
    }
  }
}

enum ZegoCallingState {
  disconnected,
  connecting,
  connected,
}

extension ZegoCallingStateExtension on ZegoCallingState {
  int get id {
    switch (this) {
      case ZegoCallingState.disconnected:
        return 0;
      case ZegoCallingState.connecting:
        return 1;
      case ZegoCallingState.connected:
        return 2;
    }
  }

  String get string {
    switch (this) {
      case ZegoCallingState.disconnected:
        return "disconnected";
      case ZegoCallingState.connecting:
        return "connecting";
      case ZegoCallingState.connected:
        return "connected";
    }
  }
}

enum ZegoDeclineType {
  kZegoDeclineTypeDecline, //  Actively refuse
  kZegoDeclineTypeBusy //  The call was busy, Passive refused
}

extension ZegoDeclineTypeExtension on ZegoDeclineType {
  int get id {
    switch (this) {
      case ZegoDeclineType.kZegoDeclineTypeDecline:
        return 1;
      case ZegoDeclineType.kZegoDeclineTypeBusy:
        return 2;
    }
  }

  static const Map<int, ZegoDeclineType> mapValue = {
    1: ZegoDeclineType.kZegoDeclineTypeDecline,
    2: ZegoDeclineType.kZegoDeclineTypeBusy,
  };

  String get string {
    switch (this) {
      case ZegoDeclineType.kZegoDeclineTypeDecline:
        return "decline";
      case ZegoDeclineType.kZegoDeclineTypeBusy:
        return "busy";
    }
  }
}

enum ZegoDeviceType {
  zegoNoiseSuppression,
  zegoEchoCancellation,
  zegoVolumeAdjustment,
}

enum ZegoVideoResolution {
  p1080,
  p720,
  p540,
  p360,
  p270,
  p180,
}

enum ZegoAudioBitrate {
  b16,
  b48,
  b56,
  b96,
  b128,
}

enum LocalUserStatus {
  /// free: Indicates that the state is idle
  free,

  /// outgoing: Indicates that a call is being made
  outgoing,

  /// incoming: Indicates that an incoming call is received
  incoming,

  /// calling: Indicates that the call is ongoing
  calling,
}

enum ZegoError {
  success,
  firebasePathNotExist,
  failed,
  paramInvalid,
  notInit,
  networkError,
  notLogin,
  callStatusWrong,
  tokenExpired,
}

extension ZegoErrorExtension on ZegoError {
  int get id {
    switch (this) {
      case ZegoError.success:
        return 0;
      case ZegoError.firebasePathNotExist:
        return 10001;

      case ZegoError.failed:
        return 1001;
      case ZegoError.paramInvalid:
        return 1002;
      case ZegoError.notInit:
        return 1003;
      case ZegoError.networkError:
        return 1004;
      case ZegoError.notLogin:
        return 1005;

      case ZegoError.callStatusWrong:
        return 2001;
      case ZegoError.tokenExpired:
        return 2002;
    }
  }
}

//  firebase command key
const String apiGetToken = "/user/get_token";
const String apiCallHeartbeat = "/call/heartbeat";
const String apiStartCall = "/call/start_call";
const String apiCancelCall = "/call/cancel_call";
const String apiAcceptCall = "/call/accept_call";
const String apiDeclineCall = "/call/decline_call";
const String apiEndCall = "/call/end_call";
//  firebase notify key
const String notifyCallInvited = "/call/notify_call_invited";
const String notifyCallCanceled = "/call/notify_call_canceled";
const String notifyCallAccept = "/call/notify_call_accept";
const String notifyCallDecline = "/call/notify_call_decline";
const String notifyCallEnd = "/call/notify_call_end";
const String notifyCallTimeout = "/call/notify_timeout";
