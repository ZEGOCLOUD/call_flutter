
enum CallingSettingPageIndex {
  mainPageIndex,
  audioBitratePageIndex,
  videoResolutionPageIndex,
}

extension CallingSettingPageIndexExtension on CallingSettingPageIndex {
  int get id {
    switch(this) {
      case CallingSettingPageIndex.mainPageIndex: return 0;
      case CallingSettingPageIndex.audioBitratePageIndex:return 1;
      case CallingSettingPageIndex.videoResolutionPageIndex:return 2;
    }
  }
}