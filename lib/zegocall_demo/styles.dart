// Flutter imports:
import 'package:flutter/material.dart';

/// colors
class StyleColors {
  static const Color dark = Color(0xff1B1B1B);
  static const Color red = Color(0xffEE1515);
  static const Color gray = Color(0xff989BA8);
  static const Color blue = Color(0xff0055FF);
  static Color blueDisableColor = blue.withOpacity(0.3);

  static const Color userListButtonBgColor = Color(0xffF3F4F7);
  static const Color userListSeparateLineColor = Color(0xffE6E6E6);

  static const Color settingsVersion = gray;
  static const Color settingsBackgroundColor = Color(0xffF4F5F6);
  static const Color settingsTitleColor = Color(0xff2A2A2A);
  static const Color settingsTitleBackgroundColor = Colors.white;
  static const Color settingsCellBackgroundColor = Colors.white;
}

/// icons
class StyleIconUrls {
  static const String navigatorBack = 'assets/images/navigator_back.png';
  static const String titleBarSettings = 'assets/images/title_bar_settings.png';

  static const String authLogo = 'assets/images/auth_logo.png';
  static const String authIconGoogle = 'assets/images/auth_icon_google.png';

  static const String userListDefault = 'assets/images/user_list_default.png';
  static const String userLIstVideoCall =
      'assets/images/user_list_video_call.png';
  static const String userListAudioCall =
      'assets/images/user_list_audio_call.png';

  static const String welcomeCardBanner =
      'assets/images/welcome_card_banner.png';
  static const String welcomeCardBg = 'assets/images/welcome_card_bg.png';
  static const String welcomeContactUs = 'assets/images/welcome_contact_us.png';
  static const String welcomeGetMore = 'assets/images/welcome_get_more.png';

  static const String settingNext = 'assets/images/setting_next.png';
  static const String settingBack = 'assets/images/setting_back.png';
  static const String settingTick = 'assets/images/settings_tick.png';
}

/// constant style
class StyleConstant {
  static const settingsFontSize = 14.0;
  static const browserFontSize = 14.0;

  static const settingTitle = TextStyle(
    color: StyleColors.dark,
    fontSize: settingsFontSize,
  );
  static const settingVersion = TextStyle(
    color: StyleColors.settingsVersion,
    fontSize: settingsFontSize,
  );
  static const settingLogout = TextStyle(
    color: StyleColors.red,
    fontSize: settingsFontSize,
  );

  static const browserTitle = TextStyle(
    color: StyleColors.dark,
    fontSize: settingsFontSize,
  );

  static const userListNameText = TextStyle(
    color: Color(0xff2A2A2A),
    fontSize: 16.0,
  );
  static const userListIDText = TextStyle(
    color: Color(0xffA4A4A4),
    fontSize: 12.0,
  );
  static const userListEmptyText = TextStyle(
    color: Color(0xffA4A4A4),
    fontSize: 15.0,
  );

  static const backText = TextStyle(
    color: Colors.blue,
    fontSize: 18.0,
  );
  static const userListTitle = TextStyle(
    color: Color(0xff2A2A2A),
    fontSize: 28.0,
  );

  static const onlineCountDown = TextStyle(
      color: Colors.white, fontSize: 16.0, decoration: TextDecoration.none);

  static const loadingText = TextStyle(
      color: Colors.white, fontSize: 10.0, decoration: TextDecoration.none);
}
