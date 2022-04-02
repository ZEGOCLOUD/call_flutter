// Dart imports:
import 'dart:developer' as developer;
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/request/zego_firebase_call_model.dart';
import 'zego_notification_call_model.dart';

const firebaseChannelKey = 'firebase_channel';

class ZegoNotificationManager {
  static var shared = ZegoNotificationManager();

  void init() {
    AwesomeNotifications()
        .initialize(
            // set the icon to null if you want to use the default app icon
            '',
            [
              NotificationChannel(
                  channelGroupKey: 'firebase_channel_group',
                  channelKey: firebaseChannelKey,
                  channelName: 'Firebase notifications',
                  channelDescription: 'Notification channel for firebase',
                  defaultColor: const Color(0xFF9D50DD),
                  playSound: true,
                  enableVibration: true,
                  vibrationPattern: lowVibrationPattern,
                  onlyAlertOnce: false,
                  ledColor: Colors.white)
            ],
            // Channel groups are only visual and are not required
            channelGroups: [
              NotificationChannelGroup(
                  channelGroupkey: 'firebase_channel_group',
                  channelGroupName: 'Firebase group')
            ],
            debug: true)
        .then(onInitFinished);
  }

  void onInitFinished(bool initResult) async {
    requestFirebaseMessagePermission();
    requestAwesomeNotificationsPermission();

    FirebaseMessaging.onBackgroundMessage(onFirebaseBackgroundMessage);

    listenAwesomeNotification();
  }

  void requestFirebaseMessagePermission() async {
    // 1. Instantiate Firebase Messaging
    String? token = await FirebaseMessaging.instance.getToken();
    developer.log("FCM Token $token");

    // 2. On iOS, this helps to take the user permissions
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    // 3. Grant permission, for iOS only, Android ignore by default
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen(onFirebaseForegroundMessage);
    } else {
      developer.log('User declined or has not accepted permission');
    }
  }

  void requestAwesomeNotificationsPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        developer
            .log('[AwesomeNotifications] requestPermissionToSendNotifications');
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((bool hasPermission) {
          developer.log(
              '[AwesomeNotifications] User granted permission: $hasPermission');
        });
      }
    });
  }

  void listenAwesomeNotification() {
    AwesomeNotifications().actionStream.listen((receivedAction) {
      if (receivedAction.channelKey != firebaseChannelKey) {
        return;
      }
      // switch (receivedAction.buttonKeyPressed) {
      // }
    });
  }

  Future<void> onFirebaseForegroundMessage(RemoteMessage message) async {
    developer.log("[firebase] foreground message: $message");
    onFirebaseRemoteMessageReceive(message);
  }

  void onFirebaseRemoteMessageReceive(RemoteMessage message) {
    developer.log('[firebase] remote message receive: ${message.data}');
    var notificationModel = ZegoNotificationCallModel.fromMap(message.data);

    Map<String, dynamic> notificationAdapter = {
      NOTIFICATION_CONTENT: {
        NOTIFICATION_ID: Random().nextInt(2147483647),
        NOTIFICATION_CHANNEL_KEY: firebaseChannelKey,
        NOTIFICATION_TITLE: notificationModel.callType.string,
        NOTIFICATION_BODY: "${notificationModel.callerName} Calling...",
        NOTIFICATION_PAYLOAD: notificationModel.callModel.toMap(),
      }
    };
    AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
  }
}

Future<void> onFirebaseBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  developer.log("[firebase] background message: $message");
  ZegoNotificationManager.shared.onFirebaseRemoteMessageReceive(message);
}
