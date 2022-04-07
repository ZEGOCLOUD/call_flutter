// Package imports:
import 'package:result_type/result_type.dart';

typedef RequestResult = Result<dynamic, ZegoError>;
typedef RequestParameterType = Map<String, dynamic>;

enum ZegoUserError {
  kickOut,
  tokenExpire,
}

extension ZegoUserErrorExtension on ZegoUserError {
  int get id {
    switch (this) {
      case ZegoUserError.kickOut:
        return 1;
      case ZegoUserError.tokenExpire:
        return 2;
    }
  }

  static const Map<int, ZegoUserError> mapValue = {
    1: ZegoUserError.kickOut,
    2: ZegoUserError.tokenExpire,
  };

  String get string {
    switch (this) {
      case ZegoUserError.kickOut:
        return "kick out";
      case ZegoUserError.tokenExpire:
        return "token expire";
    }
  }
}

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
  failed,
  paramInvalid,
  firebasePathNotExist,
}

extension ZegoErrorExtension on ZegoError {
  int get id {
    switch (this) {
      case ZegoError.failed:
        return 1;
      case ZegoError.paramInvalid:
        return 2;
      case ZegoError.firebasePathNotExist:
        return 2001;
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
const String notifyUserError = "/user/notify_error";
