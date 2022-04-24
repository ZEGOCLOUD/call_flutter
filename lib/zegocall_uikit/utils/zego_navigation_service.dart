// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

class ZegoNavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void init() {
    locator.registerLazySingleton(() => ZegoNavigationService());
  }

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }
}
