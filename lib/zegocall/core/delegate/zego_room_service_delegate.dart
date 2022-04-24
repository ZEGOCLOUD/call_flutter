mixin ZegoRoomServiceDelegate {
  /// Callback notification that room Token authentication is about to expire.
  ///
  /// Description: The callback notification that the room Token authentication is about to expire, please use [renewToken] to update the room Token authentication.
  ///
  /// @param remainTimeInSecond The remaining time before the token expires.
  /// @param roomID Room ID where the user is logged in, a string of up to 128 bytes in length.
  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond);
}
