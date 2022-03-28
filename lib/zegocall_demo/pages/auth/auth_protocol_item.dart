// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_call_flutter/utils/widgets/browser.dart';
import 'package:zego_call_flutter/zegocall_demo/constants/zego_page_constant.dart';

class AuthProtocolItem extends StatefulWidget {
  final ValueChanged<bool> updatePolicyCheckState;

  const AuthProtocolItem(this.updatePolicyCheckState, {Key? key})
      : super(key: key);

  @override
  AuthProtocolItemState createState() => AuthProtocolItemState();
}

class AuthProtocolItemState extends State<AuthProtocolItem> {
  bool isPolicyCheck = false;

  @override
  Widget build(BuildContext context) {
    const String termsOfServiceURL = "https://www.zegocloud"
        ".com/policy?index=1";
    const String privacyPolicyURL = "https://www.zegocloud"
        ".com/policy?index=0";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
            // width: 24.w,
            child: Checkbox(
          checkColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0))),
          value: isPolicyCheck,
          onChanged: (bool? value) {
            setState(() {
              isPolicyCheck = value!;
            });
            widget.updatePolicyCheckState(isPolicyCheck);
          },
        )),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText1,
              children: [
                const TextSpan(
                  text: "I have read and agree to ZEGO Call's ",
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchURL(context, termsOfServiceURL);
                    },
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchURL(context, privacyPolicyURL);
                    },
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void launchURL(BuildContext context, String targetURL) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Browser(url: targetURL, backURL: PageRouteNames.auth);
    }));
  }
}
