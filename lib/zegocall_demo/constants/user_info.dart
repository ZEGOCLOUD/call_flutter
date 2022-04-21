/// Class user information.
/// <p>Description: This class contains the user related information.</>
class UserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userID = "";

  /// User name, cannot be null.
  String userName = "";

  bool isEmpty() {
    return userID.isEmpty || userName.isEmpty;
  }

  UserInfo.empty();

  UserInfo(this.userID, this.userName);

  UserInfo clone() => UserInfo(userID, userName);

  @override
  String toString() {
    return "UserInfo [user_id=$userID,display_name=$userName";
  }

  UserInfo.fromJson(Map<String, dynamic> json)
      : userID = json['user_id'] ?? "",
        userName = json['display_name'] ?? "";

  Map<String, dynamic> toJson() => {
        'user_id': userID,
        'display_name': userName,
      };
}
