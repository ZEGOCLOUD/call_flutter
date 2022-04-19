// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../../zegocall/core/manager/zego_service_manager.dart';
import './../../styles.dart';
import './../../../../zegocall/core/interface_imp/zego_device_service_impl.dart';
import './../../../../zegocall/core/zego_call_defines.dart';
import 'calling_settings_defines.dart';
import 'calling_settings_item.dart';

class CallingSettingsListViewPage<T> extends StatelessWidget {
  final String title;

  final String selectedValue;
  final Map<T, String> model;

  final ValueChanged<int> pageIndexChanged;
  final void Function(T) onSelected;

  const CallingSettingsListViewPage(
      {required this.title,
      required this.selectedValue,
      required this.model,
      required this.pageIndexChanged,
      required this.onSelected,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32.0.w, 23.0.h, 32.0.w, 40.0.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
            child: Container(
                //  transparent decoration's target is make gesture work if click empty space
                decoration: const BoxDecoration(color: Colors.transparent),
                height: 85.h,
                child: header()),
            onTap: () {
              pageIndexChanged(CallingSettingPageIndex.mainPageIndex.id);
            }),
        SizedBox(
          width: double.infinity,
          height: 600.h,
          child: body(context),
        )
      ]),
    );
  }

  Widget header() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            SizedBox(
              width: 56.w,
              child: Image.asset(StyleIconUrls.settingBack),
            ),
            SizedBox(
              width: 18.w,
            ),
            Text(title, style: StyleConstant.callingSettingTitleText),
          ],
        ));
  }

  Widget body(BuildContext context) {
    return ListView.builder(
      itemExtent: 148.h,
      padding: EdgeInsets.only(left: 32.w, right: 32.w),
      itemCount: model.length,
      itemBuilder: (_, i) {
        var key = model.keys.elementAt(i);
        String value = model[key]!;
        return CallingSettingsListItem<T>(
          title: value,
          value: key,
          isChecked: selectedValue == value,
          onSelected: (T selectedValue) {
            onSelected(selectedValue);

            pageIndexChanged(CallingSettingPageIndex.mainPageIndex.id);
          },
        );
      },
    );
  }
}

class CallingVideoResolutionSettingsPage extends StatelessWidget {
  final ValueChanged<int> pageIndexChanged;
  final ValueChanged<String> valueChanged;
  final String selectedValue;

  const CallingVideoResolutionSettingsPage(
      {required this.pageIndexChanged,
      required this.valueChanged,
      required this.selectedValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CallingSettingsListViewPage<ZegoVideoResolution>(
        title: AppLocalizations.of(context)!.roomSettingsPageVideoResolution,
        selectedValue: selectedValue,
        model: listModel(context),
        pageIndexChanged: pageIndexChanged,
        onSelected: (ZegoVideoResolution selectedValue) {
          ZegoServiceManager.shared.deviceService
              .setVideoResolution(selectedValue);

          valueChanged(getResolutionString(selectedValue));
        });
  }

  Map<ZegoVideoResolution, String> listModel(BuildContext context) {
    Map<ZegoVideoResolution, String> model = {};
    model[ZegoVideoResolution.p180] =
        getResolutionString(ZegoVideoResolution.p180);
    model[ZegoVideoResolution.p270] =
        getResolutionString(ZegoVideoResolution.p270);
    model[ZegoVideoResolution.p360] =
        getResolutionString(ZegoVideoResolution.p360);
    model[ZegoVideoResolution.p540] =
        getResolutionString(ZegoVideoResolution.p540);
    model[ZegoVideoResolution.p720] =
        getResolutionString(ZegoVideoResolution.p720);
    model[ZegoVideoResolution.p1080] =
        getResolutionString(ZegoVideoResolution.p1080);

    return model;
  }
}

class CallingAudioBitrateSettingsPage extends StatelessWidget {
  final ValueChanged<int> pageIndexChanged;
  final ValueChanged<String> valueChanged;
  final String selectedValue;

  const CallingAudioBitrateSettingsPage(
      {required this.pageIndexChanged,
      required this.valueChanged,
      required this.selectedValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CallingSettingsListViewPage<ZegoAudioBitrate>(
        title: AppLocalizations.of(context)!.roomSettingsPageAudioBitrate,
        selectedValue: selectedValue,
        model: listModel(context),
        pageIndexChanged: pageIndexChanged,
        onSelected: (ZegoAudioBitrate selectedValue) {
          ZegoServiceManager.shared.deviceService
              .setAudioBitrate(selectedValue);

          valueChanged(getBitrateString(selectedValue));
        });
  }

  Map<ZegoAudioBitrate, String> listModel(BuildContext context) {
    Map<ZegoAudioBitrate, String> model = {};
    model[ZegoAudioBitrate.b16] = getBitrateString(ZegoAudioBitrate.b16);
    model[ZegoAudioBitrate.b48] = getBitrateString(ZegoAudioBitrate.b48);
    model[ZegoAudioBitrate.b56] = getBitrateString(ZegoAudioBitrate.b56);
    model[ZegoAudioBitrate.b96] = getBitrateString(ZegoAudioBitrate.b96);
    model[ZegoAudioBitrate.b128] = getBitrateString(ZegoAudioBitrate.b128);

    return model;
  }
}
