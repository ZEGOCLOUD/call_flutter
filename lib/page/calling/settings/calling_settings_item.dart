import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/style/styles.dart';

class CallingSettingsSwitchItem extends StatelessWidget {
  final String title;
  final bool defaultValue;
  final VoidCallback onTap;

  const CallingSettingsSwitchItem(
      {required this.title,
      required this.onTap,
      this.defaultValue = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100.h,
        child: Row(children: [
          Text(title, style: StyleConstant.callingSettingItemTitleText),
          const Expanded(child: Text('')),
          Switch(
            activeColor: StyleColors.switchActiveColor,
            activeTrackColor: StyleColors.switchActiveTrackColor,
            inactiveTrackColor: StyleColors.switchInactiveTrackColor,
            value: defaultValue,
            onChanged: (value) {
              onTap();
            },
          )
        ]));
  }
}

class CallingSettingsPageItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final VoidCallback onTap;

  const CallingSettingsPageItem(
      {required this.title,
      required this.subTitle,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100.h,
        child: Row(children: [
          Text(title, style: StyleConstant.callingSettingItemTitleText),
          const Expanded(child: Text('')),
          Text(subTitle, style: StyleConstant.callingSettingItemSubTitleText),
          SizedBox(width: 4.w),
          GestureDetector(
              onTap: onTap,
              child: SizedBox(
                width: 56.w,
                child: Image.asset(StyleIconUrls.settingNext),
              ))
        ]));
  }
}

class CallingSettingsListItem<T> extends StatelessWidget {
  final String title;
  final T value;
  final bool isChecked;

  final void Function(T) onSelected;

  const CallingSettingsListItem(
      {required this.title,
      required this.value,
      required this.isChecked,
      required this.onSelected,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: GestureDetector(
        onTap: () {
          onSelected(value);
        },
        child: Container(
            //  make gesture work if click empty space
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                Text(
                  title,
                  style: isChecked
                      ? StyleConstant.callingSettingItemTitleText
                      : StyleConstant.callingSettingItemNoCheckedTitleText,
                ),
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 56.w,
                  child: isChecked
                      ? Image.asset(StyleIconUrls.settingTick)
                      : const SizedBox(),
                ),
              ],
            )),
      ),
    );
  }
}
