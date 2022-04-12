// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'zegocall_demo/secret/zego_secret_reader.dart';
import 'zegocall_uikit/core/zego_call_manager.dart';
import 'zegocall_demo/core/zego_login_manager.dart';
import 'zegocall_demo/zegocall_demo_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  initManagers();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const ZegoApp());
  });
}

void initManagers() {
  ZegoLoginManager.shared.init();

  ZegoSecretReader.instance.loadKeyCenterData().then((_) {
    // WARNING: DO NOT USE APPID AND APPSIGN IN PRODUCTION CODE!!!GET IT FROM SERVER INSTEAD!!!
    ZegoCallManager.shared.initWithAppID(ZegoSecretReader.instance.appID);
  });
}
