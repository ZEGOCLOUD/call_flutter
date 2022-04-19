// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import '../../../../zegocall/core/manager/zego_service_manager.dart';
import '../../../../zegocall/core/zego_call_defines.dart';
import '../../styles.dart';
import 'zego_calling_settings_defines.dart';
import 'zego_calling_settings_item.dart';

class ZegoCallingSettingsPage extends HookWidget {
  final ZegoCallType callType;

  final ValueChanged<int> pageIndexChanged;
  final String audioBitrateSubTitle;
  final String videoResolutionSubTitle;

  const ZegoCallingSettingsPage(
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
    var deviceService = ZegoServiceManager.shared.deviceService;

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
        ZegoCallingSettingsSwitchItem(
          title: AppLocalizations.of(context)!.roomSettingsPageNoiseSuppression,
          defaultValue: noiseSlimming.value,
          onTap: () {
            var deviceService = ZegoServiceManager.shared.deviceService;
            deviceService.setNoiseSlimming(!deviceService.noiseSlimming);

            noiseSlimming.value = deviceService.noiseSlimming;
          },
        ),
        ZegoCallingSettingsSwitchItem(
          title: AppLocalizations.of(context)!.roomSettingsPageEchoCancellation,
          defaultValue: echoCancellation.value,
          onTap: () {
            var deviceService = ZegoServiceManager.shared.deviceService;
            deviceService.setEchoCancellation(!deviceService.echoCancellation);

            echoCancellation.value = deviceService.echoCancellation;
          },
        ),
        ZegoCallingSettingsSwitchItem(
          title: AppLocalizations.of(context)!.roomSettingsPageMicVolume,
          defaultValue: volumeAdjustment.value,
          onTap: () {
            var deviceService = ZegoServiceManager.shared.deviceService;
            deviceService.setVolumeAdjustment(!deviceService.volumeAdjustment);

            volumeAdjustment.value = deviceService.volumeAdjustment;
          },
        ),
        isVideo
            ? ZegoCallingSettingsSwitchItem(
                title: AppLocalizations.of(context)!.roomSettingsPageMinoring,
                defaultValue: isMirroring.value,
                onTap: () {
                  var deviceService = ZegoServiceManager.shared.deviceService;
                  deviceService.setIsMirroring(!deviceService.isMirroring);

                  isMirroring.value = deviceService.isMirroring;
                },
              )
            : const SizedBox(),
        isVideo
            ? ZegoCallingSettingsPageItem(
                title: AppLocalizations.of(context)!
                    .roomSettingsPageVideoResolution,
                subTitle: videoResolutionSubTitle,
                onTap: () {
                  pageIndexChanged(
                      CallingSettingPageIndex.videoResolutionPageIndex.id);
                },
              )
            : const SizedBox(),
        ZegoCallingSettingsPageItem(
          title: AppLocalizations.of(context)!.roomSettingsPageAudioBitrate,
          subTitle: audioBitrateSubTitle,
          onTap: () {
            pageIndexChanged(CallingSettingPageIndex.audioBitratePageIndex.id);
          },
        )
      ],
    );
  }
}
