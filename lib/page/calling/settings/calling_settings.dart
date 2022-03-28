import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';
import 'package:zego_call_flutter/service/zego_device_service.dart';
import 'calling_settings_defines.dart';
import 'calling_settings_page.dart';
import 'calling_settings_listview_page.dart';

class CallingSettingsView extends StatefulWidget {
  final ZegoCallType callType;

  const CallingSettingsView({required this.callType, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CallingSettingsViewState();
  }
}

class CallingSettingsViewState extends State<CallingSettingsView> {
  int pageIndex = 0;
  String audioBitrateSubTitle = "";
  String videoResolutionSubTitle = "";

  @override
  void initState() {
    pageIndex = CallingSettingPageIndexExtension
        .valueMap[CallingSettingPageIndex.mainPageIndex]!;

    var deviceService = context.read<ZegoDeviceService>();
    deviceService.getAudioBitrate().then((value) {
      updateAudioBitrate(deviceService.getBitrateString(value));
    });
    deviceService.getVideoResolution().then((value) {
      updateVideoResolution(deviceService.getResolutionString(value));
    });

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
        CallingSettingsPage(
            callType: widget.callType,
            pageIndexChanged: updateCurrentPage,
            audioBitrateSubTitle: audioBitrateSubTitle,
            videoResolutionSubTitle: videoResolutionSubTitle),
        CallingAudioBitrateSettingsPage(
            pageIndexChanged: updateCurrentPage,
            valueChanged: updateAudioBitrate,
            selectedValue: audioBitrateSubTitle),
        CallingVideoResolutionSettingsPage(
            pageIndexChanged: updateCurrentPage,
            valueChanged: updateVideoResolution,
            selectedValue: videoResolutionSubTitle),
      ],
    );
  }
}
