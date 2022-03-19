import 'dart:developer';

import 'package:flutter/cupertino.dart';
import "package:firebase_messaging/firebase_messaging.dart";

// // This provided handler must be a top-level function and cannot be anonymous otherwise an ArgumentError will be thrown.
// Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }

class ZegoCallService extends ChangeNotifier {
  late final FirebaseMessaging _messaging;

  void _registerNotification() async {
    // 1. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    String? token = await FirebaseMessaging.instance.getToken();
    log("FCM Token $token");

    // 2. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    // 3. Grant permission, for iOS only, Android ignore by default
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        log(message.notification?.title ?? "Empty Notification Title");
        log(message.notification?.title ?? "Empty Notification Body");
        log(message.data['title']);
        log(message.data['body']);
      });

      // FirebaseMessaging.onBackgroundMessage(
      //     _firebaseMessagingBackgroundHandler);
    } else {
      log('User declined or has not accepted permission');
    }
  }

  ZegoCallService() {
    _registerNotification();
  }
}