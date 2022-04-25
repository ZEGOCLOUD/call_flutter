// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../../zegocall/core/model/zego_user_info.dart';
import '../../../../zegocall/core/zego_call_defines.dart';
import '../../../core/manager/zego_call_manager.dart';
import '../../../core/manager/zego_call_manager_interface.dart';
import '../../styles.dart';
import 'zego_calling_bottom_toolbar_button.dart';

class ZegoCallingCallerBottomToolBar extends StatelessWidget {
  const ZegoCallingCallerBottomToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: Center(
        child: GestureDetector(
          onTap: () {
            ZegoCallManager.shared.cancelCall();
          },
          child: SizedBox(
            width: 120.w,
            child: Image.asset(StyleIconUrls.toolbarBottomCancel),
          ),
        ),
      ),
    );
  }
}

class ZegoCallingCalleeBottomToolBar extends StatefulWidget {
  final ZegoCallType callType;
  final ZegoUserInfo caller;
  final ZegoUserInfo callee;

  const ZegoCallingCalleeBottomToolBar(
      {required this.caller,
        required this.callee,
        required this.callType,
        Key? key})
      : super(key: key);

  @override
  State<ZegoCallingCalleeBottomToolBar> createState() {
    return ZegoCallingCalleeBottomToolBarState();
  }
}

class ZegoCallingCalleeBottomToolBarState
    extends State<ZegoCallingCalleeBottomToolBar> {
  bool isAccepting = false;
  ValueNotifier<bool> acceptingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    if (ZegoCallStatus.calling == ZegoCallManager.shared.currentCallStatus) {
      //  status is call connecting before init, mean is accepting now,
      //  so state should be accepting when render finished
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        setState(() {
          isAccepting = true;
          acceptingNotifier.value = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZegoCallingCalleeBottomToolBarButton(
              text: AppLocalizations.of(context)!.callPageActionDecline,
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: StyleIconUrls.toolbarBottomDecline,
              onTap: () {
                ZegoCallManager.shared.declineCall();
              },
            ),
            SizedBox(width: 230.w),
            ZegoCallingCalleeBottomToolBarButton(
              text: AppLocalizations.of(context)!.callPageActionAccept,
              iconWidth: 120.w,
              iconHeight: 120.h,
              iconURL: imageURLByCallType(widget.callType),
              onTap: isAccepting ? null : onAcceptTap,
              rotateIconNotifier: acceptingNotifier,
            ),
          ],
        ),
      ),
    );
  }

  void onAcceptTap() {
    setState(() {
      isAccepting = true;
      acceptingNotifier.value = true;
    });

    ZegoCallManager.shared
        .acceptCall(widget.caller, widget.callType)
        .then((value) {
      setState(() {
        // isAccepting = false;
        acceptingNotifier.value = false;
      });
    });
  }

  String imageURLByCallType(ZegoCallType callType) {
    if (isAccepting) {
      return StyleIconUrls.toolbarBottomAcceptLoading;
    }

    switch (callType) {
      case ZegoCallType.kZegoCallTypeVoice:
        return StyleIconUrls.toolbarBottomVoice;
      case ZegoCallType.kZegoCallTypeVideo:
        return StyleIconUrls.toolbarBottomVideo;
    }
  }
}