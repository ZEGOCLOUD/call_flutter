
enum CallingSettingPageIndex {
  mainPageIndex,
  audioBitratePageIndex,
  videoResolutionPageIndex,
}

extension CallingSettingPageIndexExtension on CallingSettingPageIndex {
  static const valueMap = {
    CallingSettingPageIndex.mainPageIndex: 0,
    CallingSettingPageIndex.audioBitratePageIndex: 1,
    CallingSettingPageIndex.videoResolutionPageIndex: 2,
  };
}