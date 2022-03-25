import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'package:zego_call_flutter/common/user_avatar.dart';

class AvatarBackgroundView extends StatelessWidget {
  final String userName;

  const AvatarBackgroundView({required this.userName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(userName);

    return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage("images/avatar_${avatarIndex}_big.png"),
              fit: BoxFit.fitHeight,
            ))));
  }
}
