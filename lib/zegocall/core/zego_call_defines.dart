// Package imports:
import 'package:result_type/result_type.dart';

typedef RequestResult = Result<dynamic, ZegoError>;
typedef RequestParameterType = Map<String, dynamic>;

enum ZegoUserError {
  kickOut,
}

enum ZegoCallType { kZegoCallTypeVoice, kZegoCallTypeVideo }
enum ZegoCallTimeoutType {
  kZegoCallTimeoutTypeCaller,
  kZegoCallTimeoutTypeCallee
}
enum ZegoDeclineType {
  kZegoDeclineTypeDecline, //  Actively refuse
  kZegoDeclineTypeBusy //  The call was busy, Passive refused
}

enum ZegoDeviceType {
  zegoNoiseSuppression,
  zegoEchoCancellation,
  zegoVolumeAdjustment,
}

enum ZegoVideoResolution {
  v1080P,
  v720P,
  v540P,
  v360P,
  v270P,
  v180P,
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
  static const valueMap = {
    ZegoError.failed: 1,
    ZegoError.paramInvalid: 2001,
  };

  int get value => valueMap[this] ?? -1;
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
