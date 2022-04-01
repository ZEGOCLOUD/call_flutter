/// Class room information.
/// <p>Description: This class contain the room status related information.</>
class ZegoRoomInfo {
  /// Room ID, refers to the the unique identifier of the room, can be used when joining the room.
  String roomID = "";

  /// Room name, refers to the room title, can be used for display.
  String roomName = "";

  ZegoRoomInfo(this.roomID, this.roomName);

  ZegoRoomInfo.fromJson(Map<String, dynamic> json)
      : roomID = json['id'],
        roomName = json['name'];

  Map<String, dynamic> toJson() => {
        'id': roomID,
        'name': roomName,
      };
}
