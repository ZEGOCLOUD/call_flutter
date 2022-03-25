
/// Class user information.
/// <p>Description: This class contains the user related information.</>
class ZegoUserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userID = "";

  /// User name, cannot be null.
  String displayName = "";
  bool mic = false;
  bool camera = false;

  String photoUrl = "";
  int lastChanged = 0;

  bool isEmpty() {
    return userID.isEmpty || displayName.isEmpty;
  }

  ZegoUserInfo.empty();

  ZegoUserInfo(this.userID, this.displayName, this.lastChanged);

  ZegoUserInfo clone() => ZegoUserInfo(userID, displayName, lastChanged);

  ZegoUserInfo.fromJson(Map<String, dynamic> json)
      : userID = json['user_id'] ?? "",
        displayName = json['display_name'],
        photoUrl = json['photo_url'] ??
            "https://upload.wikimedia.org/wikipedia/commons/c/cd/Portrait_Placeholder_Square.png",
        lastChanged = json['last_changed'];

  Map<String, dynamic> toJson() => {
        'user_id': userID,
        'display_name': displayName,
        'photo_url': photoUrl,
        'last_changed': lastChanged,
      };

  @override
  String toString() {
    return "UserInfo [user_id=$userID,display_name=$displayName,last_changed=$lastChanged]";
  }
}
