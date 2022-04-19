// Flutter imports:
import 'package:flutter/material.dart';

Future<T?> showModalBottomSheetWithStyle<T>(
    BuildContext context, double widgetHeight, Widget widget) {
  return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      isDismissible: true,
      builder: (BuildContext context) {
        return AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            child: SizedBox(height: widgetHeight, child: widget));
      });
}
