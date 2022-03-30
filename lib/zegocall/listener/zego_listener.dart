typedef ZegoNotifyListenerParameter = Map<String, dynamic>;
typedef ZegoNotifyListener = Function(ZegoNotifyListenerParameter);

mixin ZegoListener {
  String addListener(String path, ZegoNotifyListener listener);

  void removeListener(String path, String uuid);
}
