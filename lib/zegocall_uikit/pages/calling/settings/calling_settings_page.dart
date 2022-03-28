// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_call_service.dart';
import 'package:zego_call_flutter/zegocall/core/service/zego_device_service.dart';
import 'calling_settings_defines.dart';
import 'calling_settings_item.dart';

class CallingSettingsPage extends HookWidget {
  final ZegoCallType callType;

  final ValueChanged<int> pageIndexChanged;
  final String audioBitrateSubTitle;
  final String videoResolutionSubTitle;

  const CallingSettingsPage(
      {required this.callType,
      required this.pageIndexChanged,
      required this.audioBitrateSubTitle,
      required this.videoResolutionSubTitle,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32.0.w, 23.0.h, 32.0.w, 40.0.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 85.h, child: title()),
        SizedBox(
            height: 600.h, child: SingleChildScrollView(child: body(context)))
      ]),
    );
  }

  Widget title() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text('Settings', style: StyleConstant.callingSettingTitleText),
    );
  }

  Widget body(BuildContext context) {
    var deviceService = context.read<ZegoDeviceService>();

    var noiseSlimming =
        useState(deviceService.noiseSlimming); // sdk default value
    var echoCancellation =
        useState(deviceService.echoCancellation); // sdk default value
    var volumeAdjustment =
        useState(deviceService.volumeAdjustment); // sdk default value
    var isMirroring = useState(deviceService.isMirroring);

    var isVideo = ZegoCallType.kZegoCallTypeVideo == callType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CallingSettingsSwitchItem(
          title: 'Noise suppression',
          defaultValue: noiseSlimming.value,
          onTap: () {
            var deviceService = context.read<ZegoDeviceService>();
            deviceService.setNoiseSlimming(!deviceService.noiseSlimming);

            noiseSlimming.value = deviceService.noiseSlimming;
          },
        ),
        CallingSettingsSwitchItem(
          title: 'Echo cancellation',
          defaultValue: echoCancellation.value,
          onTap: () {
            var deviceService = context.read<ZegoDeviceService>();
            deviceService.setEchoCancellation(!deviceService.echoCancellation);

            echoCancellation.value = deviceService.echoCancellation;
          },
        ),
        CallingSettingsSwitchItem(
          title: 'Mic Volume auto-adjustment',
          defaultValue: volumeAdjustment.value,
          onTap: () {
            var deviceService = context.read<ZegoDeviceService>();
            deviceService.setVolumeAdjustment(!deviceService.volumeAdjustment);

            volumeAdjustment.value = deviceService.volumeAdjustment;
          },
        ),
        isVideo
            ? CallingSettingsSwitchItem(
                title: 'Mirroring',
                defaultValue: isMirroring.value,
                onTap: () {
                  var deviceService = context.read<ZegoDeviceService>();
                  deviceService.setIsMirroring(!deviceService.isMirroring);

                  isMirroring.value = deviceService.isMirroring;
                },
              )
            : const SizedBox(),
        isVideo
            ? CallingSettingsPageItem(
                title: 'Resolution',
                subTitle: videoResolutionSubTitle,
                onTap: () {
                  pageIndexChanged(CallingSettingPageIndexExtension.valueMap[
                      CallingSettingPageIndex.videoResolutionPageIndex]!);
                },
              )
            : const SizedBox(),
        CallingSettingsPageItem(
          title: 'Audio bitrate',
          subTitle: audioBitrateSubTitle,
          onTap: () {
            pageIndexChanged(CallingSettingPageIndexExtension
                .valueMap[CallingSettingPageIndex.audioBitratePageIndex]!);
          },
        )
      ],
    );
  }
}
