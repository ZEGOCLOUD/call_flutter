// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import '../widgets/toast_manager.dart';

Future<Set<bool>> checkPermission() async {
  var cameraPermissionStatus = await Permission.camera.request();
  var microPermissionStatus = await Permission.microphone.request();

  return {
    PermissionStatus.granted == cameraPermissionStatus,
    PermissionStatus.granted == microPermissionStatus
  };
}

void executeInPermission(BuildContext context, VoidCallback function) {
  checkPermission().then((permissionStatuses) {
    if (!permissionStatuses.first) {
      ToastManager.shared
          .showToast(AppLocalizations.of(context)!.cameraPermissionTip);
      return;
    }
    if (!permissionStatuses.last) {
      ToastManager.shared
          .showToast(AppLocalizations.of(context)!.micPermissionTip);
      return;
    }

    function();
  });
}
