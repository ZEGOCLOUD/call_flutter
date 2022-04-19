// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../logger.dart';
import '../../utils/zego_navigation_service.dart';

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

    final ZegoNavigationService _navigationService = locator<ZegoNavigationService>();
    var context = _navigationService.navigatorKey.currentContext!;

    // var n = ModalRoute.of(context)?.settings.name;
    currentRouteName = routeName;
    Navigator.pushNamed(context, routeName);
  }

  void navigatorPop() {
    final ZegoNavigationService _navigationService = locator<ZegoNavigationService>();
    Navigator.pop(_navigationService.navigatorKey.currentContext!);
  }

  void navigatePopCalling({bool isForce = false}) {
    assert(callingBackRouteName.isNotEmpty);

    navigatorPush(callingBackRouteName, isForce: isForce);
  }
}
