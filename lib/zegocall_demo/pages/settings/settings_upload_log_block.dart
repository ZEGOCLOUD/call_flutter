// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall_uikit/core/manager/zego_call_manager.dart';
import './../../styles.dart';
import './../../widgets/toast_manager.dart';

class SettingsUploadLogBlock extends StatelessWidget {
  const SettingsUploadLogBlock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: StyleColors.settingsCellBackgroundColor,
        ),
        padding: EdgeInsets.only(left: 32.w, top: 0, right: 32.w, bottom: 0),
        child: SizedBox(
            height: 98.h,
            child: InkWell(
              onTap: () {
                ToastManager.shared.showLoading();

                ZegoCallManager.interface.uploadLog().then((errorCode) {
                  ToastManager.shared.hide();

                  if (0 != errorCode) {
                    ToastManager.shared.showToast(AppLocalizations.of(context)!
                        .toastUploadLogFail(errorCode));
                  } else {
                    ToastManager.shared.showToast(
                        AppLocalizations.of(context)!.toastUploadLogSuccess);
                  }
                });
              },
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.settingPageUploadLog,
                      style: StyleConstant.settingTitle,
                      textDirection: TextDirection.ltr),
                  const Expanded(
                    child: Text(''),
                  )
                ],
              ),
            )));
  }
}
