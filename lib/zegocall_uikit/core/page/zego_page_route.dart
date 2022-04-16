// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../zegocall_demo/pages/zego_navigation_service.dart';

class ZegoPageRoute {
  static var shared = ZegoPageRoute();

  String currentRouteName = "";
  String callingBackRouteName = "";

  void navigatorPush(String routeName, {bool isForce = false}) {
    if (currentRouteName == routeName && !isForce) {
      log('[page route] $routeName is current route name');
      return;
    }

    log('[page route] push $routeName');

    final NavigationService _navigationService = locator<NavigationService>();
    var context = _navigationService.navigatorKey.currentContext!;

    // var n = ModalRoute.of(context)?.settings.name;
    currentRouteName = routeName;
    Navigator.pushNamed(context, routeName);
  }

  void navigatorPop() {
    final NavigationService _navigationService = locator<NavigationService>();
    Navigator.pop(_navigationService.navigatorKey.currentContext!);
  }

  void navigatePopCalling() {
    assert(callingBackRouteName.isNotEmpty);

    navigatorPush(callingBackRouteName);
  }
}
