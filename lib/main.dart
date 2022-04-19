// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall_demo/core/uikit_manager.dart';
import 'package:zego_call_flutter/zegocall_demo/pages/navigation_service.dart';
import 'zegocall_demo/core/login_manager.dart';
import 'zegocall_demo/secret/zego_secret_reader.dart';
import 'zegocall_demo/call_demo_app.dart';
import 'zegocall_uikit/core/manager/zego_call_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  initManagers();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    NavigationService().setupLocator();

    runApp(const CallApp());
  });
}

void initManagers() async {
  LoginManager.shared.init();

  await ZegoSecretReader.instance.loadKeyCenterData().then((_) {
    // WARNING: DO NOT USE APPID AND APPSIGN IN PRODUCTION CODE!!!GET IT FROM SERVER INSTEAD!!!
    ZegoCallManager.shared.initWithAppID(ZegoSecretReader.instance.appID);
    UIKitManager.shared.init();
  });
}
