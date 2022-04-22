// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../delegate/zego_user_service_delegate.dart';
import '../model/zego_user_info.dart';
import 'zego_service.dart';

/// Class user information management.
/// <p>Description: This class contains the user information management logics, such as the logic of log in, log out,
/// get the logged-in user info, get the in-room user list, and add co-hosts, etc. </>
abstract class IZegoUserService extends ChangeNotifier with ZegoService {
  /// A list of users in the room
  List<ZegoUserInfo> userList = [];

  /// The delegate instance of the user service.
  ZegoUserServiceDelegate? delegate;

  /// The local logged-in user information.
  ZegoUserInfo localUserInfo = ZegoUserInfo.empty();

  void setLocalUser(String userID, String userName);

  ZegoUserInfo getUserInfoByID(String userID);
}
