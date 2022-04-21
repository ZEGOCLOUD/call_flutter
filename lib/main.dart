// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'logger.dart';
import 'zegocall_demo/call_demo_app.dart';
import 'zegocall_demo/constants/page_constant.dart';
import 'zegocall_demo/core/login_manager.dart';
import 'zegocall_demo/core/uikit_manager.dart';
import 'zegocall_demo/secret/zego_secret_reader.dart';
import 'zegocall_uikit/core/manager/zego_call_manager.dart';
import 'zegocall_uikit/core/page/zego_page_route.dart';

Future<void> main() async {
  initLogger();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await initManagers();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const CallApp());
  });
}

Future<void> initManagers() async {
  await ZegoSecretReader.instance.loadKeyCenterData();

  // WARNING: DO NOT USE APP ID AND APP SIGN IN PRODUCTION CODE!!!GET IT
  // FROM SERVER INSTEAD!!!
  await ZegoCallManager.shared.initWithAppID(ZegoSecretReader.instance.appID);

  ZegoPageRoute.shared.init(PageRouteNames.calling, PageRouteNames.onlineList);
  LoginManager.shared.init();
  UIKitManager.shared.init();
}
