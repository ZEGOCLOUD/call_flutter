/// Class user information.
/// <p>Description: This class contains the user related information.</>
class ZegoUserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userID = "";

  /// User name, cannot be null.
  String userName = "";
  bool mic = false;
  bool camera = false;

  bool isEmpty() {
    return userID.isEmpty || userName.isEmpty;
  }

  ZegoUserInfo.empty();

  ZegoUserInfo(this.userID, this.userName);

  ZegoUserInfo clone() => ZegoUserInfo(userID, userName);

  ZegoUserInfo.fromJson(Map<String, dynamic> json)
      : userID = json['user_id'] ?? "",
        userName = json['display_name'],
        mic = json['mic'],
        camera = json['camera'];

  Map<String, dynamic> toJson() => {
        'user_id': userID,
        'display_name': userName,
        'mic': mic,
        'camera': camera,
      };

  @override
  String toString() {
    return "UserInfo [user_id=$userID,display_name=$userName,mic=$mic,camera=$camera";
  }
}
