// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart' show rootBundle;

class ZegoSecretReader {
  int _appID = 0;
  String _serverSecret = "";

  static ZegoSecretReader? _instance;

  int get appID {
    return _appID;
  }

  String get serverSecret {
    return _serverSecret;
  }

  Future<void> loadKeyCenterData() async {
    var jsonStr = await rootBundle.loadString("assets/key_center.json");
    var dataObj = jsonDecode(jsonStr);
    _appID = dataObj['appID'];
    _serverSecret = dataObj['serverSecret'];
  }

  ZegoSecretReader._internal();

  factory ZegoSecretReader() => _getInstance();

  static ZegoSecretReader get instance => _getInstance();

  static _getInstance() {
    _instance ??= ZegoSecretReader._internal();
    return _instance;
  }
}
