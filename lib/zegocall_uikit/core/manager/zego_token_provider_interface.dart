mixin ZegoTokenProviderInterface {
  /// You will receive a notification through this callback when obtaining a Token.
  /// - Description: This callback will be triggered when making/accepting an incoming call.
  Future<String> getRTCToken();
}
