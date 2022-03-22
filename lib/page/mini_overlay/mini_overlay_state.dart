enum MiniOverlayPageState { kIdle, kVoiceCalling, kVideoCalling }

enum MiniOverlayPageVoiceCallingState {
  kIdle,
  kWaiting,
  kOnline,
  kDeclined,
  kMissed,
  kEnded,
}

enum MiniOverlayPageVideoCallingState {
  kIdle,
  kCalleeWithVideo,
  kOnlyCallerWithVideo,
  kBothWithoutVideo,
}
