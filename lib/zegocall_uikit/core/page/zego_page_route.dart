// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../logger.dart';
import '../../../zegocall_demo/pages/navigation_service.dart';

class ZegoPageRoute {
  static var shared = ZegoPageRoute();

  String currentRouteName = "";
  String callingBackRouteName = "";

  void navigatorPush(String routeName, {bool isForce = false}) {
    if (currentRouteName == routeName && !isForce) {
      logInfo('$routeName is current route name');
      return;
    }

    logInfo('push $routeName');

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
