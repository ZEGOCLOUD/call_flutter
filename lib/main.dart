// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall_demo/firebase/zego_login_manager.dart';
import '../zegocall/core/manager/zego_service_manager.dart';
import '../zegocall/notification/zego_notification_manager.dart';
import '../zegocall/request/zego_firebase_manager.dart';
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

  ZegoServiceManager.shared.init();
  ZegoServiceManager.shared.initWithAPPID(841790877);

  ZegoFireBaseManager.shared.init();
  ZegoNotificationManager.shared.init();
}
