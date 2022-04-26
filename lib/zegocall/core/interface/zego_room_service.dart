// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../delegate/zego_room_service_delegate.dart';
import '../model/zego_room_info.dart';
import '../zego_call_defines.dart';
import 'zego_service.dart';

abstract class IZegoRoomService extends ChangeNotifier with ZegoService {
  /// Room information, it will be assigned after join the room successfully. And it will be updated synchronously when
  /// the room status updates.
  ZegoRoomInfo roomInfo = ZegoRoomInfo('', '');
  ZegoRoomServiceDelegate? delegate;

  /// Join a room
  ///
  /// Description: This method can be used to join a room, and the room must be an existing room.
  ///
  /// Call this method at: after user logs in
  ///
  /// - Parameter roomID: refers to the ID of the room you want to join, and this cannot be null.
  /// - Parameter token: refers to the Token for authentication. To get this, refer to the documentation: https://doc-en.zego.im/article/11648
  Future<ZegoError> joinRoom(String roomID, String token);

  /// Leave a room
  ///
  /// Description: This method can be used to leave the room you joined. The room will be ended when the Host left the room, and all users in the room will be forced to leave the room.
  ///
  /// Call this method at: after joining a room
  void leaveRoom();

  /// Renew token.
  ///
  /// Description: After the developer receives [onRoomTokenWillExpire], they can use this API to update the token to ensure that the subsequent RTC functions are normal.
  ///
  /// @param token The token that needs to be renew.
  /// @param roomID Room ID.
  void renewToken(String token, String roomID);
}
