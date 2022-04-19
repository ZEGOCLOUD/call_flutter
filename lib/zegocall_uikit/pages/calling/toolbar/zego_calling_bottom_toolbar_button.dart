// Flutter imports:
import 'dart:math';
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../styles.dart';

class ZegoCallingCalleeBottomToolBarButtonIcon extends StatefulWidget {
  final String iconURL;
  final double iconWidth;
  final double iconHeight;
  final ValueNotifier<bool>? rotateIconNotifier;

  const ZegoCallingCalleeBottomToolBarButtonIcon(
      {required this.iconURL,
      required this.iconWidth,
      required this.iconHeight,
      required this.rotateIconNotifier,
      Key? key})
      : super(key: key);

  @override
  State<ZegoCallingCalleeBottomToolBarButtonIcon> createState() {
    return ZegoCallingCalleeBottomToolBarButtonIconState();
  }
}

class ZegoCallingCalleeBottomToolBarButtonIconState
    extends State<ZegoCallingCalleeBottomToolBarButtonIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController acceptAnimationController;

  @override
  void initState() {
    super.initState();
    acceptAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    widget.rotateIconNotifier?.addListener(rotateNotifierChanged);
  }

  void rotateNotifierChanged() {
    if (widget.rotateIconNotifier!.value) {
      acceptAnimationController.repeat();
    } else {
      acceptAnimationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: acceptAnimationController,
      builder: (_, child) {
        return Transform.rotate(
          angle: acceptAnimationController.value * 2 * pi,
          child: child,
        );
      },
      child: Container(
        width: widget.iconWidth,
        height: widget.iconHeight,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(widget.iconURL), fit: BoxFit.fitWidth)),
      ),
    );
  }
}

class ZegoCallingCalleeBottomToolBarButton extends StatelessWidget {
  final String text;

  final String iconURL;
  final double iconWidth;
  final double iconHeight;
  final ValueNotifier<bool>? rotateIconNotifier;

  final VoidCallback? onTap;

  const ZegoCallingCalleeBottomToolBarButton(
      {this.text = "",
      required this.iconURL,
      required this.iconWidth,
      required this.iconHeight,
      required this.onTap,
      this.rotateIconNotifier,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Column(children: [
          ZegoCallingCalleeBottomToolBarButtonIcon(
              iconURL: iconURL,
              iconWidth: iconWidth,
              iconHeight: iconHeight,
              rotateIconNotifier: rotateIconNotifier),
          text.isEmpty ? const SizedBox() : SizedBox(height: 12.h),
          text.isEmpty
              ? const SizedBox()
              : Text(text, style: StyleConstant.callingButtonIconText)
        ]));
  }
}
