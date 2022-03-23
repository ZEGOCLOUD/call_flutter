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

  static const Color roomPopUpPageBackgroundColor = Colors.white;

  static const Color settingsVersion = gray;
  static const Color settingsBackgroundColor = Color(0xffF4F5F6);
  static const Color settingsTitleBackgroundColor = Colors.white;
  static const Color settingsCellBackgroundColor = Colors.white;
}

/// icons
class StyleIconUrls {
  static const String navigatorBack = 'images/navigator_back.png';
  static const String roomTopQuit = 'images/room_top_quit.png';
  static const String titleBarSettings = 'images/title_bar_settings.png';

  static const String authLogo = 'images/auth_logo.png';
  static const String authIconGoogle = 'images/auth_icon_google.png';

  static const String userListDefault = 'images/user_list_default.png';
  static const String userLIstVideoCall = 'images/user_list_video_call.png';
  static const String userListAudioCall = 'images/user_list_audio_call.png';

  static const String welcomeCardBanner = 'images/welcome_card_banner.png';
  static const String welcomeCardBg = 'images/welcome_card_bg.png';
  static const String welcomeContactUs = 'images/welcome_contact_us.png';
  static const String welcomeGetMore = 'images/welcome_get_more.png';

  static const String roomOverlayVoiceCalling = 'images/room_overlay_voice_'
      'calling.png';
}

/// constant style
class StyleConstant {
  static const appBarTitleSize = 17.0;
  static const settingsFontSize = 14.0;
  static const browserFontSize = 14.0;

  static const settingAppBar = TextStyle(
    color: Colors.black,
    fontSize: appBarTitleSize,
  );
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

  static const voiceCallingText = TextStyle(
      color: Colors.white, fontSize: 9.0, decoration: TextDecoration.none);

  static const loadingText = TextStyle(
      color: Colors.white, fontSize: 10.0, decoration: TextDecoration.none);
}
