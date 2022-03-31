/// Class user information.
/// <p>Description: This class contains the user related information.</>
class DemoUserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userID = "";

  /// User name, cannot be null.
  String userName = "";

  bool isEmpty() {
    return userID.isEmpty || userName.isEmpty;
  }

  DemoUserInfo.empty();

  DemoUserInfo(this.userID, this.userName);

  DemoUserInfo clone() => DemoUserInfo(userID, userName);

  @override
  String toString() {
    return "UserInfo [user_id=$userID,display_name=$userName";
  }

  DemoUserInfo.fromJson(Map<String, dynamic> json)
      : userID = json['user_id'] ?? "",
        userName = json['display_name'];

  Map<String, dynamic> toJson() => {
        'user_id': userID,
        'display_name': userName,
      };
}
