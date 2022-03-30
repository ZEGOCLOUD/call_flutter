/// Class room information.
/// <p>Description: This class contain the room status related information.</>
class ZegoRoomInfo {
  /// Room ID, refers to the the unique identifier of the room, can be used when joining the room.
  String roomID = "";

  /// Room name, refers to the room title, can be used for display.
  String roomName = "";

  /// Host ID, refers to the ID of the room creator.
  String hostID = "";

  /// The number of speaker seats.
  int seatNum = 0;

  /// Whether the text chat is disabled in the room.
  bool isTextMessageDisable = false;

  /// whether the speaker seat is closed.
  bool isSeatClosed = false;

  ZegoRoomInfo(this.roomID, this.roomName, this.hostID);

  ZegoRoomInfo clone() {
    var cloneObject = ZegoRoomInfo(roomID, roomName, hostID);
    cloneObject.seatNum = seatNum;
    cloneObject.isTextMessageDisable = isTextMessageDisable;
    cloneObject.isSeatClosed = isSeatClosed;
    return cloneObject;
  }

  ZegoRoomInfo.fromJson(Map<String, dynamic> json)
      : roomID = json['id'],
        roomName = json['name'],
        hostID = json['host_id'],
        seatNum = json['num'],
        isTextMessageDisable = json['disable'],
        isSeatClosed = json['close'];

  Map<String, dynamic> toJson() => {
        'id': roomID,
        'name': roomName,
        'host_id': hostID,
        'num': seatNum,
        'disable': isTextMessageDisable,
        'close': isSeatClosed
      };
}
