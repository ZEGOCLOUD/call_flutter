import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:zego_call_flutter/zegocall_demo/zegoapp.dart';

Future<void> main() async {
  FlutterBugly.postCatchedException(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        '',
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: const Color(0xFF9D50DD),
              playSound: true,
              ledColor: Colors.white)
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);

    // Declared as global, outside of any class
    Future<void> _firebaseMessagingBackgroundHandler(
        RemoteMessage message) async {
      // If you're going to use other Firebase services in the background, such as Firestore,
      // make sure you call `initializeApp` before using other Firebase services.
      await Firebase.initializeApp();

      print("Handling a background message: ${message.messageId}");

      // Use this method to automatically convert the push data, in case you gonna use our data standard
      AwesomeNotifications().createNotificationFromJsonData(message.data);
    }

    await Firebase.initializeApp();

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
