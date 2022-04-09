// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'zego_listener.dart';
import 'zego_listener_handler.dart';
import 'zego_listener_updater.dart';

class ZegoListenerManager with ZegoListener, ZegoListenerUpdater {
  static var shared = ZegoListenerManager();

  Map<String, List<ZegoListenerHandler>> listeners = {};

  @override
  String addListener(String path, ZegoNotifyListener listener) {
    var handler = ZegoListenerHandler(path, UniqueKey().toString(), listener);

    var pathListeners = listeners[path];
    pathListeners ??= [];
    if (!listeners.containsKey(path)) {
      listeners[path] = [];
    }
    listeners[path]!.add(handler);

    log('[Listener] add listener, path:$path, uuid:${handler.uid}');

    return handler.uid;
  }

  @override
  void removeListener(String path, String uuid) {
    if (!listeners.containsKey(path)) {
      return;
    }

    log('[Listener] remove listener, path:$path, uuid:$uuid');
    listeners[path]!.removeWhere((element) => element.uid == uuid);
  }

  @override
  void receiveUpdate(String path, ZegoNotifyListenerParameter parameter) {
    log('[Listener] receive update, path:$path, parameter:$parameter');

    if (!listeners.containsKey(path)) {
      return;
    }

    for (var element in listeners[path]!) {
      element.listener(parameter);
    }
  }
}
