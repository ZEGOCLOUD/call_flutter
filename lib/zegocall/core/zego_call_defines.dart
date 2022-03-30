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
