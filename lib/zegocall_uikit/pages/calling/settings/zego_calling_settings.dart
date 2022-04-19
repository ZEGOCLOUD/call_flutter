// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/core/manager/zego_service_manager.dart';
import './../../../../zegocall/core/interface_imp/zego_device_service_impl.dart';
import './../../../../zegocall/core/zego_call_defines.dart';
import 'zego_calling_settings_defines.dart';
import 'zego_calling_settings_listview_page.dart';
import 'zego_calling_settings_page.dart';

class ZegoCallingSettingsView extends StatefulWidget {
  final ZegoCallType callType;

  const ZegoCallingSettingsView({required this.callType, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ZegoCallingSettingsViewState();
  }
}

class ZegoCallingSettingsViewState extends State<ZegoCallingSettingsView> {
  int pageIndex = 0;
  String audioBitrateSubTitle = "";
  String videoResolutionSubTitle = "";

  @override
  void initState() {
    pageIndex = CallingSettingPageIndex.mainPageIndex.id;

    var deviceService = ZegoServiceManager.shared.deviceService;
    updateAudioBitrate(getBitrateString(deviceService.audioBitrate));
    updateVideoResolution(getResolutionString(deviceService.videoResolution));

    super.initState();
  }

  void updateCurrentPage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  void updateAudioBitrate(String value) {
    setState(() {
      audioBitrateSubTitle = value;
    });
  }

  void updateVideoResolution(String value) {
    setState(() {
      videoResolutionSubTitle = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: pageIndex,
      children: [
        ZegoCallingSettingsPage(
            callType: widget.callType,
            pageIndexChanged: updateCurrentPage,
            audioBitrateSubTitle: audioBitrateSubTitle,
            videoResolutionSubTitle: videoResolutionSubTitle),
        ZegoCallingAudioBitrateSettingsPage(
            pageIndexChanged: updateCurrentPage,
            valueChanged: updateAudioBitrate,
            selectedValue: audioBitrateSubTitle),
        ZegoCallingVideoResolutionSettingsPage(
            pageIndexChanged: updateCurrentPage,
            valueChanged: updateVideoResolution,
            selectedValue: videoResolutionSubTitle),
      ],
    );
  }
}
