// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ToastManager extends ChangeNotifier {
  static var shared = ToastManager();

  void init() {
    EasyLoading.instance.toastPosition = EasyLoadingToastPosition.top;
  }

  showLoading({String message = "loading..."}) {
    EasyLoading.show(status: message);
  }

  showToast(String message) {
    EasyLoading.showToast(message);
  }

  hide() {
    EasyLoading.dismiss();
  }
}
