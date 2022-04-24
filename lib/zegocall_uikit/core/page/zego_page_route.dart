// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../logger.dart';
import '../../../zegocall/utils/zego_navigation_service.dart';

class ZegoPageRoute {
  static var shared = ZegoPageRoute();

  String currentRouteName = "";

  String callingPageRouteName = "";
  String callingParentPageRouteName = "";

  void init(String callingPageRouteName, String callingParentPageRouteName) {
    this.callingPageRouteName = callingPageRouteName;
    this.callingParentPageRouteName = callingParentPageRouteName;
  }

  void push(String routeName, {bool isForce = false}) {
    if (currentRouteName == routeName && !isForce) {
      logInfo('$routeName is current route name');
      return;
    }

    logInfo('push $routeName');

    final ZegoNavigationService _navigationService =
        locator<ZegoNavigationService>();
    var context = _navigationService.navigatorKey.currentContext!;

    currentRouteName = routeName;
    Navigator.pushNamed(context, routeName);
  }

  void pop() {
    final ZegoNavigationService _navigationService =
        locator<ZegoNavigationService>();
    Navigator.pop(_navigationService.navigatorKey.currentContext!);
  }

  void popToCallingParentPage() {
    assert(callingParentPageRouteName.isNotEmpty);
    if (callingParentPageRouteName.isEmpty) {
      logInfo('parent page route name is empty');
      return;
    }

    push(callingParentPageRouteName);
  }
}
