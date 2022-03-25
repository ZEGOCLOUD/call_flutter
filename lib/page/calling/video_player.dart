import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/user_avatar.dart';
import 'avatar_background.dart';

class VideoPlayerView extends StatefulWidget {
  final String userID;
  final String userName;

  const VideoPlayerView({required this.userID, required this.userName, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerViewState();
  }
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  var isStreamReady = false;

  @override
  Widget build(BuildContext context) {
    // todo express sdk preview view, stream state to hide
    //  test
    // Future.delayed(const Duration(seconds: 5), () {
    //   setState(() {
    //     isStreamReady = true; //  todo on stream state update
    //   });
    // });
    return isStreamReady
        ? const Center(
            child: Text('Preview Frame',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 21.0,
                    decoration: TextDecoration.none)))
        : AvatarBackgroundView(userName: widget.userName);
  }
}
