// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Project imports:
import '../../logger.dart';
import '../core/manager/zego_service_manager.dart';
import '../core/model/zego_user_info.dart';
import '../core/zego_call_defines.dart';
import 'zego_notification_call_model.dart';
import 'zego_notification_ring.dart';

const firebaseChannelGroupName = 'firebase_channel_group';
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
                  channelGroupKey: firebaseChannelGroupName,
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
                  channelGroupkey: firebaseChannelGroupName,
                  channelGroupName: 'Firebase group')
            ],
            debug: true)
        .then(onInitFinished);

    ZegoNotificationRing.shared.init();
  }

  void uninit() async {
    ZegoNotificationRing.shared.uninit();
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
    logInfo("FCM Token $token");

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
      logInfo('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen(onFirebaseForegroundMessage);
    } else {
      logInfo('User declined or has not accepted permission');
    }
  }

  void requestAwesomeNotificationsPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        logInfo('requestPermissionToSendNotifications');

        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((bool hasPermission) {
          logInfo('User granted permission: $hasPermission');
        });
      }
    });
  }

  void listenAwesomeNotification() {
    //  BEFORE!! MaterialApp widget, starts to listen the notification actions
    AwesomeNotifications().actionStream.listen((receivedAction) {
      if (receivedAction.channelKey != firebaseChannelKey) {
        logInfo('unknown channel key');
        return;
      }

      var model = ZegoNotificationModel.fromMap(
          receivedAction.payload ?? <String, String>{});
      logInfo('receive:${model.toMap()}');

      //  dispatch notification message
      var caller = ZegoUserInfo(model.callerID, model.callerName);
      var callType =
          ZegoCallTypeExtension.mapValue[int.parse(model.callTypeID)] ??
              ZegoCallType.kZegoCallTypeVoice;
      ZegoServiceManager.shared.callService.delegate
          ?.onReceiveCallInvite(caller, callType);
    });
  }

  Future<void> onFirebaseForegroundMessage(RemoteMessage message) async {
    // for more reliable, faster notification in foreground
    // use listener in firebase manager
    return;

    // logInfo("[firebase] foreground message: $message");
    // onFirebaseRemoteMessageReceive(message);
  }

  Future<void> onFirebaseRemoteMessageReceive(RemoteMessage message) async {
    ZegoNotificationRing.shared.startRing();

    logInfo('remote message receive: ${message.data}');
    var notificationModel = ZegoNotificationModel.fromMessageMap(message.data);

    Map<String, dynamic> notificationAdapter = {
      NOTIFICATION_CONTENT: {
        NOTIFICATION_ID: Random().nextInt(2147483647),
        NOTIFICATION_GROUP_KEY: firebaseChannelGroupName,
        NOTIFICATION_CHANNEL_KEY: firebaseChannelKey,
        NOTIFICATION_TITLE: ZegoCallTypeExtension
                .mapValue[int.parse(notificationModel.callTypeID)]?.string ??
            "",
        NOTIFICATION_BODY: "${notificationModel.callerName} Calling...",
        NOTIFICATION_PAYLOAD: notificationModel.toMap(),
        NOTIFICATION_PLAY_SOUND: false,
        NOTIFICATION_ENABLE_VIBRATION: false,
      }
    };
    logInfo('create notification: $notificationAdapter');
    AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
  }
}

// Declared as global, outside of any class
Future<void> onFirebaseBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  // logInfo("message: ${message.data}");
  ZegoNotificationManager.shared.onFirebaseRemoteMessageReceive(message);
}
