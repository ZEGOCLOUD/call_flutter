// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../zego_call_defines.dart';
import './../delegate/zego_user_service_delegate.dart';
import './../model/zego_user_info.dart';

/// Class user information management.
/// <p>Description: This class contains the user information management logics, such as the logic of log in, log out,
/// get the logged-in user info, get the in-room user list, and add co-hosts, etc. </>
abstract class IZegoUserService extends ChangeNotifier {
  /// In-room user list, can be used when displaying the user list in the room.
  List<ZegoUserInfo> userList = [];
  ZegoUserServiceDelegate? delegate;

  /// The local logged-in user information.
  ZegoUserInfo localUserInfo = ZegoUserInfo.empty();

  void setLocalUser(String userID, String userName);

  Future<RequestResult> getToken(String userID);

  ZegoUserInfo getUserInfoByID(String userID);
}
