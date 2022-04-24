/// check these error codes at:  https://docs.zegocloud.com/article/5707
enum ZegoAssertErrorCode {
  k1000001,
  k1000037,
  k1002001,
  k1002005,
  k1002009,
  k1002010,
  k1002012,
  k1002013,
  k1002030,
  k1002031,
  k1002033,
  k1000002,
  k1000014,
  k1000015,
  k1000016,
  k1003001,
  k1003028,
  k1004001,
  k1004080,
  k1004081,
  k1006001,
  k1006002,
  k1006003
}

extension ZegoAssertErrorCodeExtension on ZegoAssertErrorCode {
  int get id {
    switch (this) {
      case ZegoAssertErrorCode.k1000001:
        return 1000001;
      case ZegoAssertErrorCode.k1000037:
        return 1000037;
      case ZegoAssertErrorCode.k1002001:
        return 1002001;
      case ZegoAssertErrorCode.k1002005:
        return 1002005;
      case ZegoAssertErrorCode.k1002009:
        return 1002009;
      case ZegoAssertErrorCode.k1002010:
        return 1002010;
      case ZegoAssertErrorCode.k1002012:
        return 1002012;
      case ZegoAssertErrorCode.k1002013:
        return 1002013;
      case ZegoAssertErrorCode.k1002030:
        return 1002030;
      case ZegoAssertErrorCode.k1002031:
        return 1002031;
      case ZegoAssertErrorCode.k1002033:
        return 1002033;
      case ZegoAssertErrorCode.k1000002:
        return 1000002;
      case ZegoAssertErrorCode.k1000014:
        return 1000014;
      case ZegoAssertErrorCode.k1000015:
        return 1000015;
      case ZegoAssertErrorCode.k1000016:
        return 1000016;
      case ZegoAssertErrorCode.k1003001:
        return 1003001;
      case ZegoAssertErrorCode.k1003028:
        return 1003028;
      case ZegoAssertErrorCode.k1004001:
        return 1004001;
      case ZegoAssertErrorCode.k1004080:
        return 1004080;
      case ZegoAssertErrorCode.k1004081:
        return 1004081;
      case ZegoAssertErrorCode.k1006001:
        return 1006001;
      case ZegoAssertErrorCode.k1006002:
        return 1006002;
      case ZegoAssertErrorCode.k1006003:
        return 1006003;
    }
  }

  static const Map<int, ZegoAssertErrorCode> mapValue = {
    1000001: ZegoAssertErrorCode.k1000001,
    1000037: ZegoAssertErrorCode.k1000037,
    1002001: ZegoAssertErrorCode.k1002001,
    1002005: ZegoAssertErrorCode.k1002005,
    1002009: ZegoAssertErrorCode.k1002009,
    1002010: ZegoAssertErrorCode.k1002010,
    1002012: ZegoAssertErrorCode.k1002012,
    1002013: ZegoAssertErrorCode.k1002013,
    1002030: ZegoAssertErrorCode.k1002030,
    1002031: ZegoAssertErrorCode.k1002031,
    1002033: ZegoAssertErrorCode.k1002033,
    1000002: ZegoAssertErrorCode.k1000002,
    1000014: ZegoAssertErrorCode.k1000014,
    1000015: ZegoAssertErrorCode.k1000015,
    1000016: ZegoAssertErrorCode.k1000016,
    1003001: ZegoAssertErrorCode.k1003001,
    1003028: ZegoAssertErrorCode.k1003028,
    1004001: ZegoAssertErrorCode.k1004001,
    1004080: ZegoAssertErrorCode.k1004080,
    1004081: ZegoAssertErrorCode.k1004081,
    1006001: ZegoAssertErrorCode.k1006001,
    1006002: ZegoAssertErrorCode.k1006002,
    1006003: ZegoAssertErrorCode.k1006003,
  };

  String get string {
    switch (this) {
      case ZegoAssertErrorCode.k1000001:
        return "Description: The engine is not initialized and cannot call non-static functions."
            "Cause: Engine not created."
            "Solutions: Please call the [createEngine] function to create the engine first, and then call the current function.";
      case ZegoAssertErrorCode.k1000037:
        return "Description: This AppID has been removed from production. "
            "Solutions: Please check the status of the AppID on the ZEGO official website console or contact ZEGO technical support.";
      case ZegoAssertErrorCode.k1002001:
        return "Description: The number of rooms the user attempted to log into simultaneously exceeds the maximum number allowed. Currently, a user can only be logged in to one main room."
            "Cause: Login multiple rooms simultaneously under single room mode."
            "Solutions: Please check is login multiple rooms simultaneously or not under single room mode.";
      case ZegoAssertErrorCode.k1002005:
        return "Description: The input user ID is empty."
            "Cause: The input user ID is empty."
            "Solutions: Please check the input user ID is empty or not.";
      case ZegoAssertErrorCode.k1002009:
        return "The input user name contains invalid characters. "
            "The user name entered by the [loginRoom] function contains illegal characters."
            "Please check the user name entered when calling the [loginRoom] "
            "function to ensure that it is only contain numbers, English characters and '~', '!', '@', '#', '\$', '%', '^', '&', '*', '(', ')', '_', '+', '=', '-', '`', ';', ',', '.', '<', '>', '/', ''.";
      case ZegoAssertErrorCode.k1002010:
        return "The input user name is too long. "
            "The length of the user name input by the [loginRoom] function is greater than or equal to 256 bytes."
            "Please check the user name entered when calling the [loginRoom] function to ensure that its length is less than 256 bytes.";
      case ZegoAssertErrorCode.k1002012:
        return "The input room ID contains invalid characters. "
            "The room ID entered by the [loginRoom] function contains illegal characters."
            "Please check the room ID entered when calling the [loginRoom] function to ensure that it is only contain numbers, English characters and '~', '!', '@', '#', '\$', '%', '^', '&', '*', '(', ')', '_', '+', '=', '-', '`', ';', ',', '.', '<', '>', '/', ''.";
      case ZegoAssertErrorCode.k1002013:
        return "The input room ID is too long."
            "The length of the room ID input by the [loginRoom] function is greater than or equal to 128 bytes."
            "Please check the room ID entered when calling the [loginRoom] function to ensure that its length is less than 128 bytes.";
      case ZegoAssertErrorCode.k1002030:
        return "Description: Login failed, possibly due to network problems. "
            "Cause: The current network is abnormal."
            "Solutions: It is recommended to switch the network to try.";
      case ZegoAssertErrorCode.k1002031:
        return "Description: Login timed out, possibly due to network problems."
            "Cause: The current network delay is large."
            "Solutions: It is recommended to switch the network to try.";
      case ZegoAssertErrorCode.k1002033:
        return "Description: Room login authentication failed. "
            "Cause: login set token error or token expired."
            "Solutions: set new token.";
      case ZegoAssertErrorCode.k1000002:
        return "Description: Not logged in to the room, unable to support function implementation."
            "Cause: Not logged in to the room."
            "Solutions: Please call [loginRoom] to log in to the room first, and use related functions during the online period after entering the room.";
      case ZegoAssertErrorCode.k1000014:
        return "Description: The input streamID is too long."
            "Cause: The length of the streamID parameter passed in when calling [startPublishingStream] or [startPlayingStream] exceeds the limit."
            "Solutions: The streamID should be less than 256 bytes.";
      case ZegoAssertErrorCode.k1000015:
        return "Description: The input StreamID is null. "
            "Cause: The streamID parameter passed in when calling [startPublishingStream] or [startPlayingStream] is null or empty string."
            "Solutions: Check whether the streamID parameter passed in when calling the function is normal.";
      case ZegoAssertErrorCode.k1000016:
        return "Description: The input streamID contains invalid characters. "
            "Cause: The streamID parameter passed in when calling [startPublishingStream] or [startPlayingStream] contains invalid characters."
            "Solutions: Check whether the streamID parameter passed in when calling the function is normal, only support numbers, english characters and '~', '!', '@', '\$', '%', '^', '&', '*', '(', ')', '_', '+', '=', '-', '`', ';', ',', '.', '<', '>', '/', ''.";
      case ZegoAssertErrorCode.k1003001:
        return "Description: Publishing failed due to no data in the stream."
            "Cause: No data in the stream."
            "Solutions: Check whether the video, audio capture module is working properly.";
      case ZegoAssertErrorCode.k1003028:
        return "Description: Failed to publish the stream. The same stream already exists in the room."
            "Cause: The same stream already exists in the room."
            "Solutions: Replace with a new stream ID. Adjust the stream ID generation strategy to ensure uniqueness.";
      case ZegoAssertErrorCode.k1004001:
        return "Description: Stream playing failed."
            "Caution: Possibly due to no data in the stream."
            "Solutions: Check to see if the publish-stream is working or try to play stream again, and if the problem is still not resolved, please contact ZEGO technical support to solve the problem.";
      case ZegoAssertErrorCode.k1004080:
        return "Description: Unsupported video decoder."
            "Caution: There is no selected video decoder in the current SDK."
            "Solutions: Please contact ZEGO technical support.";
      case ZegoAssertErrorCode.k1004081:
        return "Description: Video decoder fail."
            "Caution: Video decoder fail."
            "Solutions: Please contact ZEGO technical support.";
      case ZegoAssertErrorCode.k1006001:
        return "Description: Generic device error."
            "Cause: Device dose not work normally."
            "Solutions: Use the system's video or audio recording application to check whether the device can work normally. If the device is normal, please contact ZEGO technical support.";
      case ZegoAssertErrorCode.k1006002:
        return "Description: The device ID does not exist."
            "Cause: The device ID is spelled incorrectly, or the corresponding device is unplugged."
            "Solutions: Please use the SDK interface to obtain the device ID, and check whether the device is properly connected.";
      case ZegoAssertErrorCode.k1006003:
        return "Description: No permission to access the device."
            "Cause: Did not apply for or obtain the permission to use the corresponding device."
            "Solutions: Please check whether the application has correctly applied for the camera or microphone permission, and whether the user has granted the corresponding permission.";
    }
  }
}

void assertErrorCode(int errorCode) {
  if (!ZegoAssertErrorCodeExtension.mapValue.containsKey(errorCode)) {
    return;
  }

  var enumCode = ZegoAssertErrorCodeExtension.mapValue[errorCode]!;
  var description = enumCode.string;
  /*
     You can view the exact cause of the error through the link below
     https://docs.zegocloud.com/article/5547?w=\(errorCode)
    */
  assert(false, "Please check this error: $errorCode, $description");
}
