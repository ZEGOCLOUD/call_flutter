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

  static const Color roomPopUpPageBackgroundColor = Colors.white;

  static const Color settingsVersion = gray;
  static const Color settingsBackgroundColor = Color(0xffF4F5F6);
  static const Color settingsTitleColor = Color(0xff2A2A2A);
  static const Color settingsTitleBackgroundColor = Colors.white;
  static const Color settingsCellBackgroundColor = Colors.white;

  static const Color switchActiveColor = Colors.white;
  static const Color switchActiveTrackColor = blue;
  static const Color switchInactiveTrackColor = Color(0xff787880);
}

/// icons
class StyleIconUrls {
  static const String navigatorBack = 'images/navigator_back.png';
  static const String roomTopQuit = 'images/room_top_quit.png';
  static const String titleBarSettings = 'images/title_bar_settings.png';

  static const String authLogo = 'images/auth_logo.png';
  static const String authIconGoogle = 'images/auth_icon_google.png';

  static const String inviteVoice = 'images/invite_voice.png';
  static const String inviteVoicePressed = 'images/invite_voice_pressed.png';
  static const String inviteRejectPressed = 'images/invite_reject_pressed.png';
  static const String inviteReject = 'images/invite_reject.png';
  static const String inviteVideoPressed = 'images/invite_video_pressed.png';
  static const String inviteVideo = 'images/invite_video.png';

  static const String userListDefault = 'images/user_list_default.png';
  static const String userLIstVideoCall = 'images/user_list_video_call.png';
  static const String userListAudioCall = 'images/user_list_audio_call.png';

  static const String welcomeCardBanner = 'images/welcome_card_banner.png';
  static const String welcomeCardBg = 'images/welcome_card_bg.png';
  static const String welcomeContactUs = 'images/welcome_contact_us.png';
  static const String welcomeGetMore = 'images/welcome_get_more.png';

  static const String settingNext = 'images/setting_next.png';
  static const String settingBack = 'images/setting_back.png';
  static const String settingTick = 'images/settings_tick.png';

  static const String roomOverlayVoiceCalling = 'images/room_overlay_voice_'
      'calling.png';

  static const String toolbarBottomCameraClosed = 'images/toolbar_bottom_cam'
      'era_closed.png';
  static const String toolbarBottomCameraOpen = 'images/toolbar_bottom_camer'
      'a_open.png';
  static const String toolbarBottomCancel = 'images/toolbar_bottom_cancel.png';
  static const String toolbarBottomEnd = 'images/toolbar_bottom_cancel.png';
  static const String toolbarBottomClosed = 'images/toolbar_bottom_closed.png';
  static const String toolbarBottomDecline = 'images/toolbar_bottom_decline'
      '.png';
  static const String toolbarBottomMicClosed = 'images/toolbar_bottom_mic_cl'
      'osed.png';
  static const String toolbarBottomMicOpen = 'images/toolbar_bottom_mic_open'
      '.png';
  static const String toolbarBottomSpeakerOpen =
      'images/toolbar_bottom_speaker_open.png';
  static const String toolbarBottomSpeakerClosed = 'images/toolbar_bottom_speak'
      'er_closed.png';
  static const String toolbarBottomSwitchCamera = 'images/toolbar_bottom_swi'
      'tch_camera.png';
  static const String toolbarBottomVideo = 'images/toolbar_bottom_video.png';
  static const String toolbarBottomVoice = 'images/toolbar_bottom_voice.png';
  static const String toolbarTopMini = 'images/toolbar_top_mini.png';
  static const String toolbarTopSettings = 'images/toolbar_top_settings.png';
  static const String toolbarTopSwitchCamera = 'images/toolbar_top_switch_camera.png';
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

  static const inviteUserName = TextStyle(
    color: Colors.white,
    fontSize: 18.0,
    decoration: TextDecoration.none,
  );
  static const inviteCallType = TextStyle(
    color: Colors.white,
    fontSize: 12.0,
    decoration: TextDecoration.none,
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

  static const callingCenterUserName = TextStyle(
      color: Colors.white,
      fontSize: 21.0,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold);
  static const callingCenterStatus = TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w100);
  static const callingButtonIconText = TextStyle(
      color: Colors.white, fontSize: 13.0, decoration: TextDecoration.none);

  static const onlineCountDown = TextStyle(
      color: Colors.white, fontSize: 16.0, decoration: TextDecoration.none);

  static const voiceCallingText = TextStyle(
      color: Colors.white, fontSize: 9.0, decoration: TextDecoration.none);

  static const loadingText = TextStyle(
      color: Colors.white, fontSize: 10.0, decoration: TextDecoration.none);

  static const callingSettingTitleText = TextStyle(
    color: StyleColors.settingsTitleColor,
    fontSize: 16.0,
  );
  static const callingSettingItemTitleText = TextStyle(
    color: StyleColors.dark,
    fontSize: 15.0,
  );
  static const callingSettingItemSubTitleText = TextStyle(
    color: Color(0xffA4A4A4),
    fontSize: 14.0,
  );
  static const callingSettingItemNoCheckedTitleText = TextStyle(
    color: Color(0xffA4A4A4),
    fontSize: 15.0,
  );
}