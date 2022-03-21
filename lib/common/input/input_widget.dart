import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';

const Color sendButtonColor = Color(0xff0055FF);
Color sendButtonDisableColor = sendButtonColor.withOpacity(0.3);
const Color textBackgroundColor = Color(0xffF7F7F8);
const sendButtonText = TextStyle(
  color: Colors.white,
  fontSize: 13.0,
);

class InputWidget extends HookWidget {
  InputWidget({required this.tempEditController, Key? key}) : super(key: key);
  TextEditingController tempEditController;

  @override
  Widget build(BuildContext context) {
    final editController =
        useTextEditingController(text: tempEditController.text);
    final _areFieldsEmpty = useState<bool>(true);

    useEffect(() {
      editController.addListener(() {
        _areFieldsEmpty.value = editController.text.toString().isEmpty;
        tempEditController.text = editController.text;
      });
    }, [editController]);

    return Scaffold(
      backgroundColor: Colors.transparent,
//      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.transparent,
            ),
          ),
          SafeArea(
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 36.w,
                  ),
                  Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.only(top: 15.h, right: 22.w, bottom: 15.h),
                      decoration: const BoxDecoration(
                          color: textBackgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      alignment: Alignment.center,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: null,
                        autofocus: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(100)
                        ],
                        controller: editController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 30.w, right: 30.w, top: 20.h, bottom: 20.h),
                          border: InputBorder.none,
                          //hintStyle: TextStyle(color: Color(0xffcccccc)),
                          //hintText: ""
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (() {
                      var text = editController.text.trim();
                      // if (text.isNotEmpty) { //  if not allow empty input
                      Navigator.pop(context, text);
                      // }
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                          color: _areFieldsEmpty.value
                              ? sendButtonDisableColor
                              : sendButtonColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!.roomPageSendMessage,
                        style: sendButtonText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
