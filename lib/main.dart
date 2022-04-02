// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

// Project imports:
import '../zegocall/core/manager/zego_service_manager.dart';
import '../zegocall/notification/zego_notification_manager.dart';
import '../zegocall/request/zego_firebase_manager.dart';
import 'zegocall_demo/firebase/zego_user_list_manager.dart';
import 'zegocall_demo/zegocall_demo_app.dart';

Future<void> main() async {
  FlutterBugly.postCatchedException(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();
    initManagers();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(const ZegoApp());
      FlutterBugly.init(
        androidAppId: "6c4f086570",
        iOSAppId: "086cd4eca3",
      );
    });
  });
}

void initManagers() {
  ZegoUserListManager.shared.init();

  ZegoServiceManager.shared.init();
  ZegoServiceManager.shared.initWithAPPID(841790877);

  ZegoFireBaseManager.shared.init();
  ZegoNotificationManager.shared.init();
}
