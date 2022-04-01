// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import './../delegate/zego_room_service_delegate.dart';
import './../model/zego_room_info.dart';
import 'zego_service.dart';

/// Class LiveAudioRoom information management.
/// <p>Description: This class contains the room information management logics, such as the logic of create a room, join
/// a room, leave a room, disable the text chat in room, etc.</>
abstract class IZegoRoomService extends ChangeNotifier with ZegoService {
  /// Room information, it will be assigned after join the room successfully. And it will be updated synchronously when
  /// the room status updates.
  ZegoRoomInfo roomInfo = ZegoRoomInfo('', '');
  ZegoRoomServiceDelegate? delegate;

  /// Join a room.
  /// <p>Description: This method can be used to join a room, the room must be an existing room.</>
  /// <p>Call this method at: After user logs in</>
  ///
  /// @param roomID   refers to the ID of the room you want to join, and cannot be null.
  /// @param token    token refers to the authentication token. To get this, see the documentation:
  ///                 https://doc-en.zego.im/article/11648
  Future<int> joinRoom(String roomID, String token);

  /// Leave the room.
  /// <p>Description: This method can be used to leave the room you joined. The room will be ended when the Host
  /// leaves, and all users in the room will be forced to leave the room.</>
  /// <p>Call this method at: After joining a room</>
  void leaveRoom();
}
