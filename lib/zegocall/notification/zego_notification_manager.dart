// Dart imports:
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

// Project imports:
import '../../utils/styles.dart';
import '../core/manager/zego_service_manager.dart';
import '../core/model/zego_user_info.dart';
import '../core/zego_call_defines.dart';
import 'zego_notification_call_model.dart';

const firebaseChannelGroupName = 'firebase_channel_group';
const firebaseChannelKey = 'firebase_channel';

class ZegoNotificationManager {
  static var shared = ZegoNotificationManager();

  bool isRingTimerRunning = false;
  AudioPlayer? audioPlayer;
  late AudioCache audioCache;

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

    audioCache = AudioCache(
      prefix: 'assets/audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
  }

  void uninit() {
    stopRing();

    audioCache.clearAll();
  }

  void onInitFinished(bool initResult) async {
    requestFirebaseMessagePermission();
    requestAwesomeNotificationsPermission();

    FirebaseMessaging.onBackgroundMessage(onFirebaseBackgroundMessage);

    listenAwesomeNotification();
  }

  void stopRing() async {
    isRingTimerRunning = false;

    await audioPlayer?.release();
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
        developer.log('[awesome notification] unknown channel key');
        return;
      }

      var model = ZegoNotificationModel.fromMap(
          receivedAction.payload ?? <String, String>{});
      developer.log('[awesome notification] receive:${model.toMap()}');

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

    // developer.log("[firebase] foreground message: $message");
    // onFirebaseRemoteMessageReceive(message);
  }

  Future<void> onFirebaseRemoteMessageReceive(RemoteMessage message) async {
    if (isRingTimerRunning) {
      return;
    }

    isRingTimerRunning = true;
    audioCache.loop(callRingName).then((player) => audioPlayer = player);

    Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
      if (!isRingTimerRunning) {
        audioPlayer?.stop();

        timer.cancel();
      }

      Vibrate.vibrate();
    });

    developer.log('[firebase] remote message receive: ${message.data}');
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
    developer.log(
        '[awesome notification] create notification: $notificationAdapter');
    AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
  }
}

Future<void> onFirebaseBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  developer.log("[firebase] background message: $message");
  ZegoNotificationManager.shared.onFirebaseRemoteMessageReceive(message);
}
