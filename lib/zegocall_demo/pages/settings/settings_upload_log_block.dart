// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../../utils/styles.dart';

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
                // ZegoRoomManager.shared.uploadLog().then((errorCode) {
                //   if (0 != errorCode) {
                //     Fluttertoast.showToast(
                //         msg: AppLocalizations.of(context)!
                //             .toastUploadLogFail(errorCode),
                //         backgroundColor: Colors.grey);
                //   } else {
                //     Fluttertoast.showToast(
                //         msg:
                //             AppLocalizations.of(context)!.toastUploadLogSuccess,
                //         backgroundColor: Colors.grey);
                //   }
                // });
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
