import 'dart:developer';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import "package:firebase_messaging/firebase_messaging.dart";

import '../model/zego_user_info.dart';

// // This provided handler must be a top-level function and cannot be anonymous otherwise an ArgumentError will be thrown.
// Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }

enum ZegoCallType { kZegoCallTypeVoice, kZegoCallTypeVideo }
enum ZegoCallTimeoutType {
  kZegoCallTimeoutTypeInviter,
  kZegoCallTimeoutTypeInvitee
}

class ZegoCallService extends ChangeNotifier {
  late final FirebaseMessaging _messaging;
  late Map<String, ZegoUserInfo> _userDic;

  ZegoCallService() {
    _registerNotification();
    _addCallObserve();
  }

  late Function(ZegoUserInfo info, ZegoCallType type) onReceiveCallInvite;
  late Function(ZegoUserInfo info) onReceiveCallCancel;
  late Function(ZegoUserInfo info, ZegoCallType type) onReceiveCallResponse;
  late Function() onReceiveCallEnded;
  late Function(ZegoCallTimeoutType type) onReceiveCallTimeout;

  void updateUserDic(Map<String, ZegoUserInfo> userDic) {
    _userDic = userDic;
  }

  Future<int> callUser(
      String calleeUserID, String token, ZegoCallType type) async {
    ZegoUserInfo callee = _userDic[calleeUserID] ?? ZegoUserInfo.empty();
    if (callee.userID.isEmpty) {
      return -1;
    }
    var caller = FirebaseAuth.instance.currentUser!;

    var nowTime = DateTime.now().microsecondsSinceEpoch;
    var callID = "${caller.uid}$nowTime";
    DatabaseReference ref = FirebaseDatabase.instance.ref("call/$callID");
    var json = {
      'call_time': nowTime,
      'finish_time': 0,
      'is_video': type == ZegoCallType.kZegoCallTypeVideo,
      'users': {
        caller.uid + 'test': {
          // TODO
          "display_name": caller.displayName,
          "role": 0,
          "heartbeat_time": 0,
          "connected_time": 0
        },
        callee.userID: {
          "display_name": callee.displayName,
          "role": 1,
          "heartbeat_time": 0,
          "connected_time": 0
        }
      }
    };
    await ref.set(json);
    return 0;
  }

  Future<int> cancelCall(String userID) async {
    return 0;
  }

  Future<int> respondCall(
      String callerUserID, String token, ZegoCallType type) async {
    return 0;
  }

  Future<int> endCall() async {
    return 0;
  }

  void _registerNotification() async {
    // 1. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    // String? token = await FirebaseMessaging.instance.getToken();
    // log("FCM Token $token");

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

  void _addCallObserve() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('call');
    ref.onChildAdded.listen((event) {
      var selfUserID = FirebaseAuth.instance.currentUser?.uid;
      var callID = event.snapshot.key;
      var callInfo = event.snapshot.value as Map<dynamic, dynamic>;
      var users = callInfo['users'] as Map<String, dynamic>;
      var callerID = '';
      bool isSelfBeenCall = false;
      users.forEach((key, value) {
        if (value['role'] == 0) {
          callerID = key;
        } else if (key == selfUserID) {
          isSelfBeenCall = value['role'] == 1;
        }
      });
    });
  }
}
