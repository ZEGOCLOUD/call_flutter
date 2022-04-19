// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import './../../zegocall_uikit/pages/calling/calling_page.dart';
import './../pages/login/google_login_page.dart';
import './../pages/settings/settings_page.dart';
import './../pages/users/online_list_page.dart';
import './../pages/welcome/welcome_page.dart';

class PageRouteNames {
  static const String login = "/login";
  static const String welcome = "/welcome";
  static const String calling = "/calling";
  static const String settings = "/settings";
  static const String onlineList = "/online_list";
}


Map<String, WidgetBuilder> materialRoutes = {
  PageRouteNames.login: (context) => const GoogleLoginPage(),
  PageRouteNames.welcome: (context) => const WelcomePage(),
  PageRouteNames.settings: (context) => const SettingsPage(),
  PageRouteNames.calling: (context) => const CallingPage(),
  PageRouteNames.onlineList: (context) => const OnlineListPage(),
};