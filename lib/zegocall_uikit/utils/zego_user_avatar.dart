// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:crypto/crypto.dart';

int getUserAvatarIndex(String userName) {
  if(userName.isEmpty) {
    return 0;
  }

  var digest = md5.convert(utf8.encode(userName));
  var value0 = digest.bytes[0] & 0xff;
  return (value0 % 6).abs();
}

String getUserAvatarURLByIndex(int index) {
  return "assets/images/avatar_$index.png";
}